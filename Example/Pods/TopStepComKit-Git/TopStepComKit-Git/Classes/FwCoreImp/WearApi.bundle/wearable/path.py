#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-11-12     tyx          the first version
#

import logging
import os
import time
import traceback
import json
import re

import global_var
from mcf.mcf_utils import calculate_crc32
from urpc.services.file import FileSvc
from urpc.services.svc_utils import *
from urpc.src.ffi import *
from wearable import json_lpc

LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.path'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class Path(object):
    class Type(object):
        def __init__(self) -> None:
            super().__init__()
            self.FILE_TYPE_NON_EXISTENT = 0
            self.FILE_TYPE_DIR = 1
            self.FILE_TYPE_FILE = 2

    """
    Path: 远端文件类，提供远端文件读写/遍历等操作
        _rpc: 远程调用句柄，类内部使用
        _svc: 服务调用句柄，类内存使用
        _path: 远端绝对路径
        _file: 远端路径下的文件列表
                    字典类型，格式如下:
                    {
                        "绝对路径": File 对象,
                        "绝对路径": File 对象,
                        ...
                    }
    """

    class File(object):
        """
        File: 描述文件相关信息
            path: 绝对路径
            type: 文件类型
                    0: 远端路径不存在
                    1: 远端路径为文件夹
                    2: 远端路径为文件
            size: 文件大小
                    文件夹: 目录下文件个数
                    文件: 文件数据量大小，单位 B
            data: 文件数据
                    文件夹：字典，保存该目录下文件名信息
                        字典类型，格式如下:
                        {
                            "绝对路径": File 对象,
                            "绝对路径": File 对象,
                            ...
                        }
                    文件: 文件数据
                        注：拉取文件后，当 size 不存在或与 data 长度不一致时，会更新 size 属性
            crc32: 文件校验值
                    文件夹: 常量 0x0
                    文件: 文件 CRC32 校验值
                        注: 拉取文件后，当 crc32 不存在或与 crc32 与实际计算不一致时，会更新 crc32 属性
            time: 最后更新时间
        """

        def __init__(self, path):
            super().__init__()
            self.path = path

    def __init__(self, abspath):
        """
        远端路径类，提供路径相关的 API 操作
        :param abspath: 远端绝对路径
        """
        super().__init__()
        # 远端路径，后续操作都是基于此路径及其子路径
        if type(abspath) != str or len(abspath) == 0:
            raise TypeError('The remote type is not string')
        if abspath[0] != '/' and abspath[0] != '\\':
            raise TypeError('Illegal root path')
        # 最后一个字符为路径分割符时，切割掉最后一个路径
        if abspath[-1] == '/' or abspath[-1] == '\\':
            abspath = abspath[:-1]
        # 格式化远端路径分割符，并保存
        rpc = global_var.get('rpc')
        self._svc = FileSvc(rpc, rpc.block_size - 58)
        self._rpc = rpc
        self._path = abspath.replace('\\', '/')
        self._file = {self._path: self.File(self._path)}

    def path(self):
        """
        获取远端路径
        注：该路径为远端绝对路径
        :return: self._path
        """
        return self._path

    def file(self):
        """
        获取路径下文件信息
        :return: self._file
        """
        return self._file

    def abspath(self, remote):
        """
        获取远端绝对路径
        :param remote: 远端路径
        :return: 远端绝对路径
        """
        # 入参检查，必须是一个非空字符串
        if type(remote) != str or len(remote) == 0:
            raise TypeError('The remote type is not string')
        # 判断是否是根路径，直接返回
        if remote[0] == '/' or remote[0] == '\\':
            return os.path.normpath(remote.replace('\\', '/'))
        else:
            # 拼接根路径与远端路径，并格式化路径分隔符 /
            return os.path.normpath(os.path.join(self.path(), remote).replace('\\', '/'))

    def cache(self, remote):
        """
        从存储中查找路径的相关信息
        :param remote:远端路径
        :param file_info: 更新缓存值
        :return: None:没有查找到缓存信息 字典:查找到文件缓存信息
        """
        tmp_path = self.abspath(remote)
        if tmp_path not in self.file():
            self.file()[tmp_path] = self.File(tmp_path)
        # TODO:缓存值有失效性?
        return self.file()[tmp_path]

    def cache_update(self, file_info):
        """
        更新缓存信息
        :param file_info:文件缓存信息
        :return: 更新后的缓存信息
        """
        tmp_path = self.abspath(file_info.path)
        file_info.path = tmp_path
        file_info.time = time.time()
        self.file()[tmp_path] = file_info
        return self.cache(tmp_path)

    def type(self, remote):
        """
        获取远端路径类型。类型有  0:不存在  1:文件夹  2:文件
        :param remote: 远端路径，路径前不需要携带根
        :return: True:远端路径是一个目录 False:远端路径不是一个目录，可能是一个文件或者不存在
        """
        path = self.abspath(remote)
        # 尝试从缓存中获取
        fi = self.cache(path)
        if hasattr(fi, 'type'):
            return fi.type
        # 远程读取目录属性,打包远端路径信息
        data = Arg(U8 | ARRAY, bytearray(path + '\0', encoding="utf8"))
        # 发起服务，获取远端路径文件目录类型
        result = self._svc.rpc.exec_ffi_func(1, "is_dir", [data], need_ack=False, need_rsp=True, timeout=10)
        # 检查返回值合法性
        if result.value == 0 or result.value == 1 or result.value == 2:
            fi.type = int(result.value)
            fi = self.cache_update(fi)
        else:
            raise TypeError('Remote path type error. %d' % result.value)
        # 返回值为 1 时，远端路径为文件夹
        return fi.type

    def isdir(self, remote):
        '''
        检查一个远端路径是否是一个目录
        :param remote: 远端路径
        :return: True:远端路径是一个目录 False:远端路径不是一个目录，可能是一个文件或者不存在
        '''
        # 类型为 1 时，远端路径为文件夹
        return self.type(remote) == 1

    def isfile(self, remote):
        '''
        检查一个远端路径是否是一个文件
        :param remote:远端路径
        :return: True:远端路径是一个文件 False:远端路径不是一个文件，可能是一个文件夹或者不存在
        '''
        return self.type(remote) == 2

    def exists(self, remote):
        '''
        检查远端路径是否存在
        :param remote:远端路径
        :return: True:远端路径存在，可能是文件或文件夹 False:远端路径不存在
        '''
        return self.type(remote) == 1 or self.type(remote) == 2

    def listdir_ffi(self, remote):
        """
        获取远端路径下所有文件名
        :param remote: 远端路径，相对路径时，是相对构建对象的路径
                       注: remote 必须是一个文件夹
        :return: 文件名列表
        """
        ft = self.type(remote)
        if ft == Path.Type().FILE_TYPE_NON_EXISTENT or ft == Path.Type().FILE_TYPE_FILE:
            raise SystemError('The remote directory name is invalid. %s' % remote)
        # 查找缓存是否存有这个目录的信息
        fi = self.cache(remote)
        if hasattr(fi, 'type') and fi.type == Path.Type().FILE_TYPE_DIR and hasattr(fi, 'data'):
            # data 是一个列表，其中存储着目录信息
            file_list = []
            # 将路径做成一个列表
            for i in fi.data:
                filepath,filename = os.path.split(i.path)
                file_list.append(filename)
            return file_list
        # 缓存中没有查找到，执行远端 listdir 操作
        asb_remote = self.abspath(remote)
        dir_name = Arg(U8 | ARRAY, bytearray(asb_remote + '\0', encoding="utf8"))
        dir_list = Arg(U8 | ARRAY | EDITABLE, [0] * (self._svc.rpc.block_size - 48))
        buffer_len = Arg(U32, dir_list.value_len)
        # dir_name 为目录名
        # dir_list 为改目录下文件及文件夹的名字
        # result.value 为该目录文件及文件夹的数量
        result = self._svc.rpc.exec_ffi_func(1, "lsdir_r", [dir_name, dir_list, buffer_len], need_ack=False,
                                             need_rsp=True, timeout=5)
        if result.value == 0:
            # 文件夹空
            fi.data = []
            fi = self.cache_update(fi)
        elif result.signed() > 0:
            # 文件夹非空
            file_list = []
            dir_str = ''
            for i in dir_list.value[:]:
                dir_str += chr(i)
            this_dir = dir_str.split('&')[0:result.value]
            for d in this_dir:
                tmp_abspath = self.abspath(str(remote) + '/' + str(d.split(":")[0]).replace('\\', '/'))
                tmp_fi = self.File(tmp_abspath)
                if "DIR" in d:
                    # 发现一个目录文件，加入到列表中
                    tmp_fi.type = Path.Type().FILE_TYPE_DIR
                else:
                    # 发现一个普通文件，加入到列表中
                    tmp_fi.type = Path.Type().FILE_TYPE_FILE
                tmp_fi = self.cache_update(tmp_fi)
                file_list.append(tmp_fi)
            fi.data = file_list
            fi = self.cache_update(fi)
        else:
            # 发生错误,触发异常
            raise OSError("list dir({0}) failed. error code = {1}".format(asb_remote, result.signed()))
        # 返回目录信息
        file_list = []
        for i in fi.data:
            filepath, filename = os.path.split(i.path)
            file_list.append(filename)
        # TODO: 删除多余log
        logger.info('read dir:' + self.abspath(remote) + ' -> ' + json.dumps(file_list))
        return file_list

    def listdir_svc(self, remote):
        """
        获取远端路径下所有文件名
        :param remote: 远端路径，相对路径时，是相对构建对象的路径
                       注: remote 必须是一个文件夹
        :return: 文件名列表
        """
        ft = self.type(remote)
        if ft == Path.Type().FILE_TYPE_NON_EXISTENT or ft == Path.Type().FILE_TYPE_FILE:
            raise SystemError('The remote directory name is invalid. %s' % remote)
        # 查找缓存是否存有这个目录的信息
        fi = self.cache(remote)
        if hasattr(fi, 'type') and fi.type == Path.Type().FILE_TYPE_DIR and hasattr(fi, 'data'):
            # data 是一个列表，其中存储着目录信息
            file_list = []
            # 将路径做成一个列表
            for i in fi.data:
                filepath,filename = os.path.split(i.path)
                file_list.append(filename)
            return file_list
        # 缓存中没有查找到，执行远端 listdir 操作
        asb_remote = self.abspath(remote)
        dir_name = bytearray(asb_remote + '\0', encoding="utf8")
        # dir_name 为目录名
        result = self._svc.rpc.exec_svc(1, "lsdir_svc", dir_name, need_ack=False, need_rsp=True, timeout=5)
        json_o = json.loads(result.decode('utf-8'))
        # file_array与file_count 为该目录文件及文件夹的数量
        file_count = json_o["count"]
        file_array = json_o["array"]

        if file_count == 0:
            # 文件夹空
            fi.data = []
            fi = self.cache_update(fi)
        elif file_count > 0:
            # 文件夹非空
            file_list = []
            for item in file_array:
                for file_path, file_type in item.items():
                    logger.info("file type = %s, file path = %s, ", file_type, file_path)
                    tmp_abspath = self.abspath(str(remote) + '/' + str(file_path).replace('\\', '/'))
                    tmp_fi = self.File(tmp_abspath)
                    if file_type == "DIR":
                        # 发现一个目录文件，加入到列表中
                        tmp_fi.type = Path.Type().FILE_TYPE_DIR
                    else:
                        # 发现一个普通文件，加入到列表中
                        tmp_fi.type = Path.Type().FILE_TYPE_FILE
                    tmp_fi = self.cache_update(tmp_fi)
                    file_list.append(tmp_fi)
            fi.data = file_list
            fi = self.cache_update(fi)
        else:
            # 发生错误,触发异常
            raise OSError("list dir({0}) failed. error code = {1}".format(asb_remote, file_count))
        # 返回目录信息
        file_list = []
        for i in fi.data:
            filepath, filename = os.path.split(i.path)
            file_list.append(filename)
        # TODO: 删除多余log
        logger.info('read dir:' + self.abspath(remote) + ' -> ' + json.dumps(file_list))
        return file_list

    def listdir(self, remote):
        """
        获取远端路径下所有文件名
        :param remote: 远端路径，相对路径时，是相对构建对象的路径
                       注: remote 必须是一个文件夹
        :return: 文件名列表
        """
        if self._svc.rpc.compare_version("2.2.0") > 0:
            logger.info("The current version is later than 2.2.0, use the <lsdir_svc> interface.")
            return self.listdir_svc(remote)
        else:
            logger.info("The current version is earlier than 2.2.0, use the <lsdir_r> interface.")
            return self.listdir_ffi(remote)

    def crc32(self, remote):
        """
        计算远端文件 CRC32 值
        :param remote:远端文件路径
        :return: 文件 CRC32 值
        """
        abs_remote = self.abspath(remote)
        # 获取远端路径类型
        ft = self.type(abs_remote)
        if ft == Path.Type().FILE_TYPE_NON_EXISTENT or ft == Path.Type().FILE_TYPE_DIR:
            raise SystemError('The remote file name is invalid. %d' % abs_remote)
        # 查询缓存
        fi = self.cache(abs_remote)
        if hasattr(fi, 'type') and fi.type == Path.Type().FILE_TYPE_FILE and hasattr(fi, 'crc32'):
            return fi.crc32
        # 获取远端文件 CRC32 值
        file_path = Arg(U8 | ARRAY, bytearray(abs_remote + '\0', encoding="utf8"))
        crc32 = Arg(U8 | ARRAY | EDITABLE, list(range(4)))
        result = self._rpc.exec_ffi_func(1, "calc_file_crc32", [file_path, crc32], need_ack=False,
                                       need_rsp=True, timeout=60)
        if result.signed() == -10:
            # 设备不存在该文件，执行 push 操作
            raise SystemError("file: {} not exits, result: {}".format(abs_remote, result.signed()))
        elif result.signed() == -5:
            raise SystemError("check crc32 failed. device alloc memory failed")
        elif result.signed() == 0:
            remote_crc32 = 0
            # 获取 CRC32 成功，进行对比
            for val in crc32.value[0:4]:
                remote_crc32 = (remote_crc32 << 8) + val
            if remote_crc32 > 0xFFFFFFFF:
                raise SystemError("calc crc32 error. %x" % remote_crc32)
            fi.crc32 = remote_crc32
            fi = self.cache_update(fi)
        else:
            # 未知返回值，抛出异常
            raise OSError("remote {} return value exception".format(abs_remote, result.signed()))
        logger.info('crc32: %s -> %08x' % (abs_remote, fi.crc32))
        return fi.crc32
