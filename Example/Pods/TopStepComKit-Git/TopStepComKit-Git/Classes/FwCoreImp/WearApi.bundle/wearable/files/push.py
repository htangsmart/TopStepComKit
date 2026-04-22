import logging

import os
import global_var
import time
import traceback
from .utils import *
from pathlib import Path
from mcf.mcf_utils import calculate_crc32
from urpc.services.file import FileSvc
from urpc.services.svc_utils import *
from urpc.src.ffi import *
from wearable import json_lpc, path

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.files.push'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def file_push_cb(event, status, path, start_time, cur_size, total_size):
    return file_cb('file_trans', status, event, path, start_time, cur_size, total_size)


def push_file(local, remote, sync, continue_write=True, callback=file_push_cb):
    rpc = global_var.get('rpc')
    start_time = time.time()
    try:
        svc = FileSvc(rpc, rpc.block_size - 58)
        local_path = Path(local)
        if local_path.is_dir():
            # TODO 暂不支持
            logger.error("Invalid file path. %s" % local)
            return
        # 推送文件时，判断本地文件是否存在，避免在计算 crc 时报错
        elif not local_path.exists():
            callback("onFailed", svc.status(524), remote, start_time, 0, 0)
            callback("onComplete", svc.status(524), remote, start_time, 0, 0)
        else:
            # 判断文件路径
            # 输入为 /test 时， 远端文件名为 test
            # 输入为 /test/ 时， test 为文件夹，远端文件名为本地文件名 file_name
            if remote[-1] == '/':
                # 获取本地文件名
                file_name = os.path.basename(local_path)
                remote = os.path.join(remote, file_name)
            if sync:
                local_size = os.path.getsize(local_path)
                callback("onProcess", svc.status(200), remote, start_time, 0, local_size)
                result = file_is_need_sync(rpc, svc, local_path, remote, callback)
                if result == FAIL_FLAG:
                    callback("onFailed", svc.status(531), remote, start_time, 0, local_size)
                    callback("onComplete", svc.status(200), remote, start_time, 0, local_size)
                elif result == SYNC_FLAG or result == REMOTE_FILE_NOT_FOUND_FLAG:
                    if continue_write is True:
                        # 断点续传接口会自动计算文件sha值，确定是否需要同步
                        svc.fs_continue_write(local_path, remote, callback)
                    else:
                        # 如果文件存在，先删除文件，在传输新文件
                        remove(remote)
                        svc.fs_write(local_path, remote, callback)
                elif result == SKIP_FLAG:
                    logger.info('file skip. %s' % remote)
                    callback("onSuccess", svc.status(200), remote, start_time, local_size, local_size)
                    callback("onComplete", svc.status(200), remote, start_time, local_size, local_size)
            else:
                if continue_write is True:
                    svc.fs_continue_write(local_path, remote, callback)
                else:
                    svc.fs_write(local_path, remote, callback)
    except Exception as e:
        callback("onFailed", svc.status(500, str()), remote, start_time, 0, 0)
        callback("onComplete", svc.status(200), remote, start_time, 0, 0)
        logger.error(traceback.format_exc())


def push(local, remote, sync, continue_write=True, callback=file_push_cb):
    rpc = global_var.get('rpc')
    start_time = time.time()
    try:
        svc = FileSvc(rpc, rpc.block_size - 58)
        local_path = Path(local)

        if local_path.is_dir():
            remote_path = path.Path(remote)
            if remote_path.isfile('.'):
                remove(remote_path.abspath('.'))
                remote_path = path.Path(remote)
            if not remote_path.exists('.'):
                result = None
                def __fs_mkdir_result(event, status, path, file_start_time, cur_size, total_size):
                    result = event
                svc.fs_mkdir(remote_path.abspath('.'), dir = True, callback = __fs_mkdir_result)
                if result == None or result == 'onFailed':
                    raise SystemError('fs_mkdir path. %s failed' % remote_path.abspath('.'))

                remote_path = path.Path(remote)
                logger.info("svc.fs_mkdir(remote_path.abspath('.')) %s" % remote_path.abspath('.'))
            # 刷新远端目录缓存
            remote_path = path.Path(remote)

            # 遍历远端路径
            def __list_remote_dir(p):
                nonlocal remote_path
                tmp_list = remote_path.listdir(p)
                file_list = []
                for l in tmp_list:
                    tmp_path = os.path.join(p, l).replace('\\', '/')
                    if remote_path.isdir(tmp_path):
                        # 递归查找远端路径信息
                        file_list = file_list + [tmp_path]
                        file_list = file_list + __list_remote_dir(tmp_path)
                    elif remote_path.isfile(tmp_path):
                        file_list = file_list + [tmp_path]
                return file_list

            # 遍历本地路径
            def __list_local_dir(p):
                abs_local_path = os.path.abspath(os.path.join(local, p))
                tmp_list = os.listdir(abs_local_path)
                file_list = []
                for l in tmp_list:
                    tmp_path = os.path.join(p, l).replace('\\', '/')
                    tmp_abs_path = os.path.join(abs_local_path, l)
                    if os.path.isdir(tmp_abs_path):
                        # 递归查找本地路径信息
                        file_list = file_list + [tmp_path]
                        file_list = file_list + __list_local_dir(tmp_path)
                    elif os.path.isfile(tmp_abs_path):
                        file_list = file_list + [tmp_path]
                return file_list

            # 获取差异项
            def __list_diff(local_list, remote_list):
                local_dict = {}
                __diff_list = []
                __same_list = []
                for i in local_list:
                    local_dict[i] = i
                remote_dict = {}
                for i in remote_list:
                    remote_dict[i] = i
                # 遍历列表查找差异项
                for i in remote_list:
                    if i not in local_dict:
                        # 查找本地路径不存在，远端路径存在的项
                        __diff_list = __diff_list + [i]
                        logger.info('Local exist, remote not exist. %s' % remote_path.abspath(i))
                    else:
                        local_full_path = os.path.abspath(os.path.join(local, i))
                        remote_full_path = remote_path.abspath(i)
                        # 本地及远端都是文件，校验 crc32 值
                        if os.path.isfile(local_full_path) and remote_path.isfile(remote_full_path):
                            local_crc32 = None
                            remote_crc32 = None
                            # 计算本地文件 CRC 值
                            with open(local_full_path, "rb") as f:
                                local_file = f.read()
                                local_crc32 = calculate_crc32(local_file)
                            # 计算远端 crc32 值
                            remote_crc32 = remote_path.crc32(remote_full_path)
                            # 比较 CRC3
                            if local_crc32 is None or remote_crc32 is None or local_crc32 != remote_crc32:
                                # crc32 不一样
                                __diff_list = __diff_list + [i]
                                logger.info('Local %s crc32(%x), remote %s crc32(%x)' %
                                            (local_full_path, local_crc32, remote_full_path, remote_crc32))
                            elif local_crc32 is not None and remote_crc32 is not None and local_crc32 == remote_crc32:
                                # crc32 相同
                                __same_list = __same_list + [i]
                                # 跳过相同文件
                                remote_asb_path = remote_path.abspath(i)
                                curr_time = time.time()
                                local_size = os.path.getsize(os.path.join(local, i))
                                logger.info('file skip. %s %d' % (remote_asb_path, local_size))
                                callback("onSuccess", svc.status(200), remote_path.abspath(i), curr_time, local_size, local_size)
                                callback("onComplete", svc.status(200), remote_path.abspath(i), curr_time, local_size, local_size)

                return __diff_list, __same_list

            # 获取远端路径信息
            remote_file_list = __list_remote_dir('.')
            # 获取本地路径信息
            local_file_list = __list_local_dir('.')
            # 获取删除列表
            if sync:
                diff_list, same_list = __list_diff(local_file_list, remote_file_list)
            else:
                diff_list = remote_file_list
                same_list = []
            # 执行删除操作
            diff_list = sorted(diff_list, reverse=True)
            for i in diff_list:
                remote_asb_path = remote_path.abspath(i)
                logger.info('remove path:%s' % remote_asb_path)
                remove(remote_asb_path)
            # 开始同步不同文件
            same_list = sorted(same_list, reverse=False)
            local_file_list = sorted(local_file_list, reverse=False)
            for i in local_file_list:
                if i in same_list:
                    # 如果文件在相应列表中，跳过这个文件
                    continue
                fs_write_ok = True
                abs_local_path = os.path.join(local, i)
                # 本地是一个文件夹
                if os.path.isdir(abs_local_path):
                    logger.info('push dir: ' + str(abs_local_path))
                    if remote_path.isfile(i):
                        # 远端是一个文件，则删除该文件
                        remove(os.path.normpath(remote_path.abspath(i)))
                    elif not remote_path.exists(i):
                        # 远端路径不存在，创建文件夹
                        logger.info('mkdir %s' % os.path.normpath(remote_path.abspath(i)))
                        logger.info('type %d' % remote_path.type(i))
                        svc.fs_mkdir(os.path.normpath(remote_path.abspath(i)), dir=True)
                elif os.path.isfile(abs_local_path):
                    # 本地路径是一个文件，传输这个文件
                    logger.info('push file: ' + str(abs_local_path))

                    def __callback(event, status, path, file_start_time, cur_size, total_size):
                        if event == "onFailed":
                            nonlocal fs_write_ok
                            fs_write_ok = False
                        return callback(event, status, path, file_start_time, cur_size, total_size)

                    if continue_write is True:
                        svc.fs_continue_write(abs_local_path, remote_path.abspath(i), __callback)
                    else:
                        svc.fs_write(abs_local_path, remote_path.abspath(i), __callback)
                    # 当文件写出错时，及时返回
                    if not fs_write_ok:
                        logger.error('fs_write %s failed, break' % abs_local_path)
                        break
        elif local_path.is_file():
            # 本地路径是一个文件，传输这个文件
            push_file(local, remote, sync, continue_write, callback)
        else:
            raise SystemError('invalid path. %s' % local)
    except Exception as e:
        callback("onFailed", svc.status(500, str(e)), remote, start_time, 0, 0)
        callback("onComplete", svc.status(200), remote, start_time, 0, 0)
        logger.error(traceback.format_exc())


def service_file_push(input):
    __callback__ = generate_callback(input)

    push(input['local'], input['remote'], input['sync'], input['continue_write'], callback=__callback__)
    return json_lpc.gen_success_output_json()
