#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-12-11     tyustli      the first version
#
import logging
from pathlib import Path
import zlib
import hashlib
import os
import sys

from urpc.src.ffi import *
from urpc.src.urpc_utils import *
from .svc_utils import *


LOG_LVL = logging.INFO
LOG_TAG = 'file'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

O_RDONLY = 0o00  # 8 进制数据
O_WRONLY = 0o01
O_RDWR = 0o02
O_CREAT = 0o100
O_APPEND = 0o200
O_TRUNC = 0o1000

SEEK_END = 0x02
SEEK_SET = 0x00

# 在 UDB 2.0 之后，每个 packet 大小最大都是 daemon 端 pkt_size 的最大值，已经将效率最大化，所以无需设置该数量
MAX_PACK_NUM = 0


class FileSvc:
    def __init__(self, rpc, block_size):
        self.rpc = rpc
        self.daemon_id  = rpc.daemon_id
        self.block_size = block_size
        self.trans_support_ack = self.rpc.d2d.translayer.support_ack
        self.remote_dir = list()
        self.STATUS_TABLE = {
            200: "OK",
            500: "general error",
            502: "wearservice link disconnect",
            510: "remote file/folder was NOT found",
            511: "remote file open failed",
            512: "remote file open timeout",
            513: "remote file truncate failed",
            514: "remote file truncate timeout",
            515: "remote folder create failed",
            516: "remote folder create timeout",
            517: "remote file write failed",
            518: "remote file write timeout",
            519: "remote file read failed",
            520: "remote file read timeout",
            521: "remote file close failed",
            522: "remote file close timeout",
            523: "remote file length error",
            524: "local file/folder was NOT found",
            525: "remote file access timeout",
            526: "remote file sha1 timeout",
            527: "remote file remove timeout",
            528: "remote file rename timeout",
            529: "remote file lseek timeout",
            530: "remote file statfs timeout",
            531: "check file failed"
        }
        logger.debug("file class init ok")

    def status(self, code, msg = ""):
        if len(msg) != 0:
            return {'code': code, 'msg': msg}
        if code in self.STATUS_TABLE:
            return {'code': code, 'msg': self.STATUS_TABLE[code]}
        else:
            return {'code': code, 'msg': 'Unkonw Error'}

    def __fs_open(self, file, open_flag, callback=process_file_bar_cb, decompress=None):
        file_name = Arg(U8 | ARRAY, bytearray(file + '\0', encoding="utf8"))
        flags = Arg(U32, open_flag)
        try:
            if decompress is None:
                fd = self.rpc.exec_ffi_func(self.daemon_id, "open", [file_name, flags], need_ack=False,
                                            need_rsp=True, timeout=3)
            else:
                buffer_len = Arg(U32, decompress.value_len)
                fd = self.rpc.exec_ffi_func(self.daemon_id, "dec_open", [file_name, flags, decompress, buffer_len],
                                            need_ack=False, need_rsp=True, timeout=3)
        except Exception as e:
            callback("onFailed", self.status(511), file, 0, 0, 0)
            raise Exception("open '{}' failed".format(file))

        if fd.signed() >= 0:
            logger.debug("file open success")
        else:
            logger.error("file open failed: '{}', error code: {}".format(file, fd.signed()))
            return None

        return fd

    def __fs_exception_cleanup(self, fd, is_cleanup=True, callback=process_file_bar_cb):
        cleanup = Arg(U32, int(is_cleanup))
        try:
            result = self.rpc.exec_ffi_func(self.daemon_id, "exception_cleanup", [fd, cleanup],
                                            need_ack=False, need_rsp=True, timeout=3)
            if result.signed() == 0:
                logger.debug("remote fd: '{0}' set exception cleanup success.".format(fd))
                return True
            else:
                logger.debug("remote fd: '{0}' set exception cleanup failed.".format(fd))
                return False
        except UrpcSvcNotFoundException:
            return False

    def fs_write(self, local, remote, callback=process_file_bar_cb):
        try:
            f = open(local, mode="rb")
            file = f.read()
            f.close()
        except Exception:
            callback("onFailed", self.status(524), remote, 0, 0, 0)
            callback("onComplete", self.status(200), remote, 0, 0, 0)
            return
        self.data_write(file, remote, 0, failed_cleanup=True, callback=callback)

    def data_read(self, remote, callback=process_file_bar_cb):
        fd = self.__fs_open(remote, O_RDONLY, callback)
        if fd is None:
            callback("onFailed", self.status(510), remote, 0, 0, 0)
            raise Exception("remote object '{}' does not exist.".format(remote))

        read_length = 0
        arg_seek_set = Arg(U32, SEEK_SET)
        arg_seek_end = Arg(U32, SEEK_END)
        arg_u32_0 = Arg(U32, 0)
        arg_size = self.rpc.exec_ffi_func(self.daemon_id, "lseek", [fd, arg_u32_0, arg_seek_end], need_ack=False,
                                          need_rsp=True, timeout=3)

        file_length = arg_size.value
        start_time = time.time()

        if file_length == 0:
            # 空文件
            self.__fs_close(fd, callback)
            return bytes(), file_length, True

        try:
            self.rpc.exec_ffi_func(1, "lseek", [fd, arg_u32_0, arg_seek_set], need_ack=False, need_rsp=True,
                                   timeout=3)
            offset = 0
            data = bytes()
            while file_length > 0:
                if file_length < self.block_size:
                    read_length = file_length
                else:
                    read_length = self.block_size

                arg_offset = Arg(U32, offset)
                buffer = Arg(U8 | ARRAY | EDITABLE, [0] * read_length)
                buffer_len = Arg(U32, buffer.value_len)

                try:
                    result = self.rpc.exec_ffi_func(1, "read_by_offset", [fd, arg_offset, buffer, buffer_len],
                                                    need_ack=False, need_rsp=True, timeout=3)
                except UrpcTimeoutException:
                    self.__fs_close(fd, callback)
                    callback("onFailed", self.status(520), remote, start_time, arg_size.value - file_length,
                             arg_size.value)
                    raise Exception("client wait response timeout, an exception occurred in the udb link.")
                if result.signed() != read_length:
                    logger.error("read file failed (%d!=%d)", result.signed(), read_length)
                    callback("onFailed", self.status(519), remote, start_time, arg_size.value - file_length,
                             arg_size.value)
                    break
                read_length += result.value
                file_length -= result.value
                offset += result.value
                data = data + bytes(buffer.value)
                if callback("onProcess", self.status(200), remote, start_time, arg_size.value - file_length,
                            arg_size.value):
                    break
            self.__fs_close(fd, callback)
        except Exception:
            self.__fs_close(fd, callback)
            callback("onFailed", self.status(524), remote, start_time, arg_size.value - file_length, arg_size.value)
            return data, arg_size.value, False
        else:
            if file_length == 0:
                result = True
            else:
                callback("onFailed", self.status(524), remote, start_time, arg_size.value - file_length, arg_size.value)
                result = False
            return data, arg_size.value, result

    def fs_read(self, local, remote, callback=process_file_bar_cb):
        data, file_length, result = self.data_read(remote, callback)
        if result and file_length == 0:
            # 空文件, 本地创建空文件
            open(local, mode='wb').close()
            callback("onSuccess", self.status(200), remote, 0, 0, 0)
            callback("onComplete", self.status(200), remote, 0, 0, 0)
            return file_length
        elif result and file_length > 0 and file_length == len(data):
            localPath = Path(local)

            file_name = os.path.basename(remote)

            if os.path.isdir(local):
                local += "/{}".format(file_name)

            if not localPath.parent.exists():
                os.makedirs(localPath.parent)
            f = open(local, mode='wb')
            f.write(data)
            f.close()
            callback("onSuccess", self.status(200), remote, 0, 0, 0)
            callback("onComplete", self.status(200), remote, 0, 0, 0)
            return file_length
        else:
            callback("onComplete", self.status(200), remote, 0, 0, 0)
            return 0

    def __fs_close(self, fd, callback=process_file_bar_cb, decompress=None):
        try:
            if decompress is None:
                self.rpc.exec_ffi_func(self.daemon_id, "close", [fd], need_ack=False,
                                       need_rsp=True, timeout=3)
            else:
                self.rpc.exec_ffi_func(self.daemon_id, "dec_close", [fd, decompress], need_ack=False,
                                       need_rsp=True, timeout=3)
        except UrpcTimeoutException:
            callback("onFailed", self.status(522), '', 0, 0, 0)
            raise Exception("link abnormal")

    def fs_mkdir(self, remote, dir=False, callback=process_file_bar_cb):
        dir_path = '/'
        dirs = None
        if '/' in remote:
            if dir:
                dirs = remote.split('/')[1:]
            else:
                dirs = remote.split('/')[1:-1]
        result = True
        for dir in dirs:
            dir_path += dir + '/'
            if dir_path in self.remote_dir:
                continue
            logger.debug("mkdir dir path: {0}".format(dir_path))
            dir_name = Arg(U8 | ARRAY, bytearray(dir_path + '\0', encoding="utf8"))
            dir_mode = Arg(U32, 0)
            try:
                result = self.rpc.exec_ffi_func(self.daemon_id, "mkdir_r", [dir_name, dir_mode], need_ack=False,
                                                need_rsp=True, timeout=3)
            except UrpcTimeoutException:
                callback("onFailed", self.status(516), remote, 0, 0, 0)
                raise Exception("device mkdir '{}' failed.".format(remote))
            except UrpcDisconnectException:
                callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, remote, 0, 0, 0)
                raise UrpcDisconnectException()

            if result.signed() != 0:
                if result.signed() != -1:
                    logger.error("mkdir failed: '{0}', error code: {1}".format(dir_path, result.signed()))
                    callback("onFailed", self.status(515), remote, 0, 0, 0)
                    return None
                elif result.signed() == -1:
                    logger.debug("dir: '{0}' exits".format(dir_path))
                    self.remote_dir.append(dir_path)
            else:
                self.remote_dir.append(dir_path)
        return result

    def fs_access(self, remote, callback=process_file_bar_cb):
        try:
            file_name = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
            result = self.rpc.exec_ffi_func(self.daemon_id, "access", [file_name], need_ack=False,
                                            need_rsp=True, timeout=3)
            if result.signed() == 0:
                logger.debug("remote: '{0}' is exist.".format(remote))
                return True
            else:
                logger.debug("remote: '{0}' is not exist.".format(remote))
                return False
        except UrpcTimeoutException:
            callback("onFailed", self.status(525), remote, 0, 0, 0)
            raise Exception("device access '{}' failed.".format(remote))
        except UrpcDisconnectException:
            callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, remote, 0, 0, 0)
            raise UrpcDisconnectException()

    def fs_sha1(self, remote, offset, length, callback=process_file_bar_cb):
        try:
            file_name = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
            file_offs = Arg(U32, offset)
            file_size = Arg(U32, length)
            file_sha1 = Arg(U8 | ARRAY | EDITABLE, list(range(20)))
            result = self.rpc.exec_ffi_func(self.daemon_id, "calc_file_sha1",
                                            [file_name, file_offs, file_size, file_sha1],
                                            need_ack=False, need_rsp=True, timeout=90)
            if result.signed() == -10:
                logger.debug("remote: '{0}' is not exist.".format(remote))
                return ''
            elif result.signed() == -5:
                logger.debug("remote: '{0}' calculate sha1 malloc failed.".format(remote))
                return ''
            elif result.signed() == 0:
                # 获取 SHA1 成功，进行对比
                remote_sha1 = "".join(['%02x' % i for i in file_sha1.value[0:20]])
                logger.info("remote: '{0}' sha1 is '{1}'.".format(remote, remote_sha1))
                return remote_sha1
            else:
                return -1
        except UrpcTimeoutException:
            callback("onFailed", self.status(526), remote, 0, 0, 0)
            raise Exception("device calculate part sha1 '{}' failed.".format(remote))
        except UrpcDisconnectException:
            callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, remote, 0, 0, 0)
            raise UrpcDisconnectException()
        except UrpcSvcNotFoundException:
            callback('onFailed', {'code': 500, 'msg': 'Service Not Found'}, remote, 0, 0, 0)
            raise Exception("file sha1 calculate service not found.")

    def fs_remove(self, remote, callback=process_file_bar_cb):
        try:
            file_path = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
            result = self.rpc.exec_ffi_func(self.daemon_id, "remove", [file_path], need_ack=False,
                                            need_rsp=True, timeout=3)
            if result.signed() == 0:
                logger.debug("remote: '{0}' remove success.".format(remote))
                return True
            else:
                logger.debug("remote: '{0}' remove failed.".format(remote))
                return False
        except UrpcTimeoutException:
            callback("onFailed", self.status(527), remote, 0, 0, 0)
            raise Exception("device remove '{}' failed.".format(remote))
        except UrpcDisconnectException:
            callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, remote, 0, 0, 0)
            raise UrpcDisconnectException()

    def fs_rename(self, old, new, callback=process_file_bar_cb):
        try:
            old_name = Arg(U8 | ARRAY, bytearray(old + '\0', encoding="utf8"))
            new_name = Arg(U8 | ARRAY, bytearray(new + '\0', encoding="utf8"))
            result = self.rpc.exec_ffi_func(self.daemon_id, "rename", [old_name, new_name], need_ack=False,
                                            need_rsp=True, timeout=3)
            if result.signed() == 0:
                logger.debug("remote: '{}' rename to '{}' success.".format(old, new))
                return True
            else:
                logger.debug("remote: '{}' rename to '{}' failed.".format(old, new))
                return False
        except UrpcTimeoutException:
            callback("onFailed", self.status(528), old, 0, 0, 0)
            raise Exception("device file '{}' rename to '{}' timeout.".format(old, new))
        except UrpcDisconnectException:
            callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, old, 0, 0, 0)
            raise UrpcDisconnectException()

    def fs_statfs(self, remote, callback=process_file_bar_cb):
        try:
            path = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
            block_size = Arg(U32 | EDITABLE, 0)
            block_count = Arg(U32 | EDITABLE, 0)
            block_free = Arg(U32 | EDITABLE, 0)
            result = self.rpc.exec_ffi_func(self.daemon_id, "statfs", [path, block_size, block_count, block_free],
                                            need_ack=False, need_rsp=True, timeout=3)
            if result.signed() >= 0:
                logger.debug("remote: '{}' statfs success, bsize '{}',blocks '{}',bfree '{}'.".format(
                    remote, block_size.value, block_count.value, block_free.value))
                return block_size.value, block_count.value, block_free.value
            else:
                logger.warning("remote: '{}' statfs failed.".format(remote))
                return 0, 0, 0
        except UrpcTimeoutException:
            callback("onFailed", self.status(530), remote, 0, 0, 0)
            raise Exception("device file '{}' get statfs timeout.".format(remote))
        except UrpcDisconnectException:
            callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, remote, 0, 0, 0)
            raise UrpcDisconnectException()

    def __fs_lseek(self, fd, offset, whence, callback=process_file_bar_cb):
        try:
            arg_seek_offset = Arg(U32, offset)
            arg_seek_whence = Arg(U32, whence)
            arg_size_return = self.rpc.exec_ffi_func(self.daemon_id, "lseek", [fd, arg_seek_offset, arg_seek_whence],
                                                     need_ack=False, need_rsp=True, timeout=3)
            return arg_size_return.value
        except UrpcTimeoutException:
            callback("onFailed", self.status(529), '', 0, 0, 0)
            raise Exception("device lseek '{}' failed.")
        except UrpcDisconnectException:
            callback('onFailed', {'code': 502, 'msg': 'Service Disconnect'}, '', 0, 0, 0)
            raise UrpcDisconnectException()

    def data_write(self, data, remote, write_offset, failed_cleanup=False, callback=process_file_bar_cb):
        try:
            self.fs_mkdir(remote, False, callback)
        except Exception as e:
            raise Exception("data continue write mkdir '{}' failed.".format(remote))
        need_zlib = False
        file = data
        file_len = Arg(U32, len(file))
        decompress = None
        # TODO test:disable zlib mode
        if self.rpc.zlib and write_offset == 0:
            zlib_file = zlib.compress(file)
            if len(zlib_file) * 2 < len(file):
                logger.debug("file need decompress， size： {}".format(len(zlib_file)))
                need_zlib = True
                file = zlib_file
        # remote support zlib
        if self.rpc.zlib and need_zlib:
            decompress = Arg(U8 | ARRAY | EDITABLE, list(range(4)))
        # 远端文件名与文件大小
        cache = remote + '.cache'
        # 依据不同的模式打开文件
        if write_offset > 0:
            fd = self.__fs_open(cache, O_RDWR, callback, decompress)
            self.__fs_lseek(fd, write_offset, SEEK_SET)
        else:
            fd = self.__fs_open(cache, O_RDWR | O_CREAT | O_TRUNC, callback, decompress)

        if fd is None:
            raise Exception("open '{}' fail.".format(remote))

        # 传输失败是否清理缓存文件
        if failed_cleanup is True:
            self.__fs_exception_cleanup(fd, is_cleanup=True, callback=callback)

        count = len(file) - write_offset
        total = len(file)
        offset = write_offset
        # 压缩传输模式下，远端待写入文件的 offset
        dec_write_offset = write_offset
        start_time = time.time()

        while count > 0:
            if count > self.block_size:
                write_length = self.block_size
            else:
                write_length = count
            count -= write_length
            fs_buff = file[offset:offset + write_length]
            buffer = Arg(U8 | ARRAY, fs_buff)
            buffer_len = Arg(U32, buffer.value_len)

            try:
                if self.rpc.zlib and need_zlib:
                    arg_offset = Arg(U32, dec_write_offset)
                    decompress = Arg(U8 | ARRAY, decompress.value)
                    result = self.rpc.exec_ffi_func(self.daemon_id, "dec_write_by_offset",
                                                    [fd, arg_offset, buffer, buffer_len, decompress], need_ack=False,
                                                    need_rsp=True, timeout=10)
                else:
                    arg_offset = Arg(U32, offset)
                    result = self.rpc.exec_ffi_func(self.daemon_id, "write_by_offset",
                                                    [fd, arg_offset, buffer, buffer_len], need_ack=False, need_rsp=True,
                                                    timeout=10)
                if result.signed() <= 0:
                    logger.error("write file (%s) failed (%d!=%d)", remote, result.signed(), write_length)
                    callback("onFailed", self.status(517), remote, start_time, total - count, total)
                    break
                if self.rpc.zlib and need_zlib:
                    # 如果使用的是压缩数据传输，则返回值为解压后写入远端文件的长度
                    offset += buffer_len.value
                    dec_write_offset = dec_write_offset + result.signed()
                    logger.debug("decompress file offset (%d), offset = (%d), buffer_len.value = (%d)",
                                 dec_write_offset, offset, buffer_len.value)
                else:
                    # 如果未使用压缩传输，则返回值就是写入远端文件的数据长度
                    offset += result.signed()
            except UrpcTimeoutException:
                self.__fs_close(fd, callback, decompress)
                callback("onFailed", self.status(518), remote, start_time, total - count, total)
                callback("onComplete", self.status(200), remote, start_time, total - count, total)
                raise Exception("client wait response timeout, an exception occurred in the udb link.")
            except UrpcDisconnectException:
                callback("onFailed", self.status(502), remote, start_time, total - count, total)
                callback("onComplete", self.status(200), remote, start_time, total - count, total)
                raise Exception("WearService link disconnect")
            if self.rpc.zlib and need_zlib:
                # 如果是压缩传输，则需要设置总长度为文件的原始长度，如果为压缩文件长度，传输完成后会导致校验失败
                total = file_len.value
            if callback("onProcess", self.status(200), remote, start_time, total - count, total):
                logger.info("user int callback quit initiative.")
                break
        self.__fs_close(fd, callback, decompress)
        if count <= 0:
            if self.rpc.zlib and need_zlib and dec_write_offset != file_len.value:
                logger.error("remote zlib write size:%d != file size:%d", dec_write_offset, file_len.value)
                callback("onFailed", self.status(517), remote, start_time, dec_write_offset, file_len.value)
                write_result = False
            else:
                # 如果目标文件存在，则首先删除目标文件
                if self.fs_access(remote, callback) is True:
                    self.fs_remove(remote, callback)
                # 循环60秒，等待文件重命名成功，防止上次未关闭的fd，导致重命名失败
                retry_times = 60
                while retry_times > 0:
                    # 是否重命名成功
                    if self.fs_rename(cache, remote, callback) is True:
                        break
                    retry_times = retry_times - 1
                    time.sleep(1)
                # 如果目标文件存在，则返回传输成功
                if self.fs_access(remote, callback) is True:
                    callback("onSuccess", self.status(200), remote, start_time, total - count, total)
                    write_result = True
                else:
                    callback("onFailed", self.status(517), remote, start_time, total - count, total)
                    write_result = False
        else:
            logger.error("count error {}".format(count))
            callback("onFailed", self.status(517), remote, start_time, total - count, total)
            write_result = False

        callback("onComplete", self.status(200), remote, start_time, total - count, total)
        return write_result

    def fs_continue_write(self, local, remote, callback=process_file_bar_cb):
        # 缓存文件
        cache = remote + '.cache'
        # 读取本地文件的数据
        fd = open(local, mode="rb")
        local_data = fd.read()
        fd.close()
        # 判断远端是否存在待同步文件
        if self.fs_access(remote, callback) is True:
            # 计算本地文件sha1
            local_file_sha1 = hashlib.sha1(local_data).hexdigest()
            # 计算远端文件sha1
            remote_file_sha1 = self.fs_sha1(remote, 0, 0, callback)
            # 判断本地文件的sha1与远端文件的sha1是否一致
            if local_file_sha1 == remote_file_sha1:
                # sha1一致，跳过文件同步
                start_time = time.time()
                local_size = len(local_data)
                callback("onSuccess", self.status(200), remote, start_time, local_size, local_size)
                return True
            else:
                # sha1不一致，删除远端文件
                self.fs_remove(remote, callback)
        # 判断远端是否存在待同步文件的缓存文件
        if self.fs_access(cache, callback) is True:
            # 以只读的方式打开缓存文件
            fd = self.__fs_open(cache, O_RDWR, callback=callback)
            # 读取缓存文件的文件长度
            cache_file_len = self.__fs_lseek(fd, 0, SEEK_END, callback)
            # 读取文件长度后关闭文件
            self.__fs_close(fd, callback=callback)
            # 如果缓存文件的文件长度大于mtu的长度，则说明可以进行断点续传
            if cache_file_len > self.block_size:
                # 缓存文件的文件长度向下对齐到mtu的整数倍
                align_len = align_down(cache_file_len, self.block_size)
                # 计算本地文件sha1
                local_file_sha1 = hashlib.sha1(local_data[0:align_len]).hexdigest()
                # 计算缓存文件sha1
                cache_file_sha1 = self.fs_sha1(cache, 0, align_len, callback)
                # 判断本地文件的sha1与缓存文件的sha1是否一致
                if local_file_sha1 == cache_file_sha1:
                    # sha1一致，在目前的基础上追加数据
                    return self.data_write(local_data, remote, align_len, False, callback)
                else:
                    # sha1不一致，删除远端文件
                    self.fs_remove(cache, callback)
            else:
                # 如果缓存文件的文件长度小于mtu的长度，无法续传，删除缓存文件
                self.fs_remove(cache, callback)
        # 重新写入远端文件
        return self.data_write(local_data, remote, 0, False, callback)

    def fs_file_size(self, remote, fs_continue, callback=process_file_bar_cb):
        # 判断远端是否存在同名文件，存在，返回文件长度
        if self.fs_access(remote, callback) is True:
            # 以只读的方式打开缓存文件
            fd = self.__fs_open(remote, O_RDWR, callback=callback)
            # 读取缓存文件的文件长度
            remote_file_len = self.__fs_lseek(fd, 0, SEEK_END, callback)
            # 读取文件长度后关闭文件
            self.__fs_close(fd, callback=callback)
            # 判断本地文件的长度与远端文件的长度是否一致
            return remote_file_len
        # 如果上层调用了断点续传接口，需要判断远端是否存在待同步文件的缓存文件，存在，返回文件长度
        cache = remote + '.cache'
        if fs_continue is True and self.fs_access(cache, callback) is True:
            # 以只读的方式打开缓存文件
            fd = self.__fs_open(cache, O_RDWR, callback=callback)
            # 读取缓存文件的文件长度
            cache_file_len = self.__fs_lseek(fd, 0, SEEK_END, callback)
            # 读取文件长度后关闭文件
            self.__fs_close(fd, callback=callback)
            # 如果缓存文件的文件长度大于mtu的长度，则说明可以进行断点续传
            return cache_file_len
        # 远端文件不存在，返回0
        return 0
