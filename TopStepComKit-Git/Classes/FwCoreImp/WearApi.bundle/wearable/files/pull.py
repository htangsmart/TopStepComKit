import logging
from wearable import json_lpc
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
from wearable import json_lpc
from wearable import path
import json
from urpc.src.urpc_utils import *
LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.files.pull'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

def file_pull_cb(event, status, path, start_time, cur_size, total_size):
    return file_cb('file_trans', status, event, path, start_time, cur_size, total_size)


def generate_pull_dir_callback(input, file_count, total_size):
    total_cur_size = 0
    last_cur_size = 0
    complete_file_count = 0
    def __dir_pull_cb(event, status, path, start_time, cur_size, cur_total_size):
        nonlocal total_cur_size
        nonlocal complete_file_count
        nonlocal last_cur_size

        total_cur_size += (cur_size - last_cur_size)

        last_cur_size = cur_size

        _event = event

        if event == "onSuccess" or event == "onComplete" or event == "onFailed":
            if event == "onSuccess" or event == "onFailed":
                last_cur_size = 0
                complete_file_count += 1
            if complete_file_count < file_count:
                _event = "onProgress"
            else:
                total_cur_size = total_size

        msg = {
            'code': status['code'],
            'msg': status['msg'],
            'values': {'path': path, 'start_time': start_time, 'cur_size': total_cur_size, 'total_size': total_size}
        }
        

        cb_input = {'module': input["_module"], 'event': _event, 'msg': msg}

        return json_lpc.invoke_callback(cb_input, input)
    return __dir_pull_cb


def pull_dir(svc, remote, local, sync, input, callback):
    """拉取远端文件夹"""

    _def_callback = callback

    # 先获取远端目录下所有文件的总大小
    try:
        path = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
        file_count = Arg(U32 | EDITABLE, 0)
        file_total_size = Arg(U32 | EDITABLE, 0)

        result = svc.rpc.exec_ffi_func(svc.daemon_id, "statdir", [path, file_count, file_total_size],
                                        need_ack=False, need_rsp=True, timeout=3)
        if result.signed() >= 0:
            callback = generate_pull_dir_callback(input, file_count.value, file_total_size.value)
        
    except UrpcSvcNotFoundException as e:
        pass
    except UrpcDisconnectException as e:
        callback("onFailed", svc.status(530), remote, 0, 0, 0)
        return
    except UrpcTimeoutException as e:
        callback("onFailed", svc.status(530), remote, 0, 0, 0)
        return


    def __list_dir_ffi(remote, local, files_size=0, skip_files=0, pull_files=0):
        # 遍历文件夹
        c_remote = remote
        dir_name = Arg(U8 | ARRAY, bytearray(c_remote + '\0', encoding="utf8"))
        dir_list = Arg(U8 | ARRAY | EDITABLE, [0] * (svc.rpc.block_size - 48))
        buffer_len = Arg(U32, dir_list.value_len)
        # dir_name 为目录名
        # dir_list 为改目录下文件及文件夹的名字
        # result.value 为该目录文件及文件夹的数量
        result = svc.rpc.exec_ffi_func(1, "lsdir_r", [dir_name, dir_list, buffer_len], need_ack=False,
                                       need_rsp=True, timeout=5)
        if result.value == 0:
            # 远端为空文件夹, 本地创建空文件夹
            dir_path = Path(local).joinpath(Path(remote).name)
            if not dir_path.parent.exists():
                os.makedirs(dir_path)
        elif result.signed() > 0:
            dir_str = ''
            for i in dir_list.value[:]:
                dir_str += chr(i)
            this_dir = dir_str.split('&')[0:result.value]
            for dir in this_dir:
                if "DIR" in dir:
                    this_dir_path = str(remote) + '/' + str(dir.split(":")[0]).replace('\\', '/')
                    local_path = str(local) + '/' + str(dir.split(":")[0])
                    # 该路径为文件夹，进行迭代
                    if not os.path.exists(local_path):
                        os.makedirs(local_path)
                    files_size, skip_files, pull_files = __list_dir_ffi(this_dir_path, local_path, files_size, skip_files,
                                                                    pull_files)
                else:
                    # 该路径为文件,进行 pull 文件操作
                    this_file_path = os.path.join(remote, str(dir.split(":")[0])).replace('\\', '/')
                    local_path = Path(str(local) + '/' + str(dir.split(":")[0]))
                    if not local_path.parent.exists():
                        os.makedirs(local_path.parent)
                    print("pull: {0} -> {1}".format(this_file_path, local_path))
                    try:
                        file_length, skip_file = fs_read_sync(svc, str(local_path), this_file_path, sync, callback)
                        skip_files += skip_file
                    except Exception as e:
                        skip_files += 1
                    else:
                        files_size += file_length
                        pull_files += 1
        else:
            # 发生错误,触发异常或者跳过?
            raise OSError("pull dir failed. error code = {0}".format(result.signed()))

        return files_size, skip_files, pull_files

    def __list_dir_svc(remote, local, files_size=0, skip_files=0, pull_files=0):
        # 遍历文件夹
        c_remote = remote
        dir_name = bytearray(c_remote + '\0', encoding="utf8")
        # dir_name 为目录名
        result = svc.rpc.exec_svc(1, "lsdir_svc", dir_name, need_ack=False, need_rsp=True, timeout=5)
        json_o = json.loads(result.decode('utf-8'))
        # file_array与file_count 为该目录文件及文件夹的数量
        file_count = json_o["count"]
        file_array = json_o["array"]

        if file_count == 0:
            # 远端为空文件夹, 本地创建空文件夹
            dir_path = Path(local).joinpath(Path(remote).name)
            if not dir_path.parent.exists():
                os.makedirs(dir_path)
        elif file_count > 0:
            for item in file_array:
                for file_path, file_type in item.items():
                    logger.info("file type = %s, file path = %s, ", file_type, file_path)
                    if "DIR" == file_type:
                        this_dir_path = str(remote) + '/' + str(file_path).replace('\\', '/')
                        local_path = str(local) + '/' + str(file_path)
                        # 该路径为文件夹，进行迭代
                        if not os.path.exists(local_path):
                            os.makedirs(local_path)
                        files_size, skip_files, pull_files = __list_dir_svc(this_dir_path, local_path, files_size, skip_files,
                                                                        pull_files)
                    else:
                        # 该路径为文件,进行 pull 文件操作
                        this_file_path = os.path.join(remote, str(file_path)).replace('\\', '/')
                        local_path = Path(str(local) + '/' + str(file_path))
                        if not local_path.parent.exists():
                            os.makedirs(local_path.parent)
                        try:
                            file_length, skip_file = fs_read_sync(svc, str(local_path), this_file_path, sync, callback)
                            skip_files += skip_file
                        except Exception as e:
                            skip_files += 1
                        else:
                            files_size += file_length
                            pull_files += 1
        else:
            # 发生错误,触发异常或者跳过?
            raise OSError("pull dir failed. error code = {0}".format(file_count))

        return files_size, skip_files, pull_files

    
    start_time = time.time()
    if svc.rpc.compare_version("2.2.0") > 0:
        logger.debug("The current version is later than 2.2.0, use the <lsdir_svc> interface.")
        files_size, skip_files, pull_files = __list_dir_svc(remote, local)
    else:
        logger.debug("The current version is earlier than 2.2.0, use the <lsdir_r> interface.")
        files_size, skip_files, pull_files = __list_dir_ffi(remote, local)
    end_time = time.time()
    used_time = end_time - start_time
    
    print("{0} files pulled, {1} files skipped.".format(pull_files, skip_files))
    print(StrOfSize(int(files_size / used_time)), "/s(", StrOfSize(files_size), "in",
          int(used_time * 1000) / 1000, "s )")


def fs_read_sync(svc, local, remote, sync, callback):
    rpc = global_var.get('rpc')
    start_time = time.time()
    if sync:
        # 同步模式，进行 crc32 校验
        file_length = 1
        skip_file = 0
        need_sync = file_is_need_sync(rpc, svc, local, remote, callback)
        if need_sync == SYNC_FLAG or need_sync == LOCAL_FILE_NOT_FOUND_FLAG:
            file_length = svc.fs_read(local, remote, callback)
            return file_length, skip_file
        if need_sync == FAIL_FLAG:
            callback("onFailed", svc.status(531), remote, start_time, 0, 0) 
            callback("onComplete", svc.status(200), remote, start_time, 0, 0)
            skip_file = 1
            return file_length, skip_file
        if need_sync == SKIP_FLAG:
            local_size = os.path.getsize(local)
            logger.debug("crx32 equal skip file")
            callback("onSuccess", svc.status(200), remote, start_time, local_size, local_size)
            callback("onComplete", svc.status(200), remote, start_time, local_size, local_size)
            skip_file = 1
            file_length = local_size
            return file_length, skip_file
        if need_sync == REMOTE_FILE_NOT_FOUND_FLAG:
            callback("onFailed", svc.status(510), remote, start_time, 0, 0) 
            callback("onComplete", svc.status(200), remote, start_time, 0, 0)
            skip_file = 1
            return file_length, skip_file
    else:
        return svc.fs_read(local, remote, callback)




def fs_pull(svc, remote, local, sync, input, callback):
    # 1. 执行 pull 命令时， 需要判断 remote 是否为文件夹
    # 字符串结束符
    start_time = time.time()
    remote_name = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
    result = svc.rpc.exec_ffi_func(1, "is_dir", [remote_name], need_ack=False,
                                   need_rsp=True, timeout=10)
    if result.value == 1:
        # 判断为文件夹, 执行拉取文件夹操作
        local_path = Path(local)
        if not local_path.parent.exists():
            # 判断输入路径是否存在, 创建文件夹
            os.makedirs(local_path.parent)
        pull_dir(svc, remote, local_path, sync, input, callback)

    elif result.value == 2:
        # 判断为文件, 直接 read
        logger.debug("{0} is file".format(remote))
        fs_read_sync(svc, local, remote, sync, callback)
    else:
        # 文件不存在, 执行失败回调
        logger.error("{0} not exits".format(remote))
        callback("onFailed", svc.status(510), remote, start_time, 0, 0)
        callback("onComplete", svc.status(200), remote, start_time, 0, 0)

def pull(local, remote, sync, input, callback=file_pull_cb):
    try:
        rpc = global_var.get('rpc')
        start_time = time.time()
        svc = FileSvc(rpc, rpc.block_size - 58)
        fs_pull(svc, remote, local, sync, input, callback)

    except Exception as e:
        logger.error(traceback.format_exc())
        callback("onFailed", svc.status(500, str(e)), remote, start_time, 0, 0)
        callback("onComplete", svc.status(200), remote, start_time, 0, 0)
        raise Exception(traceback.format_exc())


def service_file_pull(input):
    __callback__ = generate_callback(input)
    try:
        pull(input['local'], input['remote'], input['sync'], input, callback=__callback__)
    except Exception as e:
        # 增加异常捕获，避免异常传递到 lpc 导致重复执行回调
        pass
    return json_lpc.gen_success_output_json()