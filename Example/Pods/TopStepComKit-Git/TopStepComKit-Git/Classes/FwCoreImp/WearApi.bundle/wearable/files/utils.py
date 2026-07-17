import logging
from wearable import json_lpc
from urpc.src.ffi import *
from mcf.mcf_utils import calculate_crc32
from pathlib import Path
import global_var

LOG_LVL = logging.INFO
LOG_TAG = 'wearable.files.utils'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

SKIP_FLAG = 1 # 跳过同步
SYNC_FLAG = 2 # 需要同步文件
FAIL_FLAG = 3 # crc 校验失败
REMOTE_FILE_NOT_FOUND_FLAG = 4 # 远端文件不存在，根据推/拉 不同场景进行判断，推送文件时需要同步，拉取文件时返回失败
LOCAL_FILE_NOT_FOUND_FLAG = 5 # 本地文件不存在，推送文件时返回失败，拉取文件时需要同步


def remove(remote):
    rpc = global_var.get('rpc')
    file_path = Arg(U8 | ARRAY, bytearray(remote + '\0', encoding="utf8"))
    result = rpc.exec_ffi_func(1, "remove", [file_path], need_ack=False,
                        need_rsp=True, timeout=10)
    return result


def file_cb(module, status, event, path, start_time, cur_size, total_size):

    msg = {
        'code': status['code'],
        'msg': status['msg'],
        'values': {'path': path, 'start_time': start_time, 'cur_size': cur_size, 'total_size': total_size}
    }
    # 将字典转换成 json， ios 中 swift 无法解析字典
    input = {'module': module, 'event': event, 'msg': msg}
    return json_lpc.invoke_callback(input)


def generate_callback(input):
    def __file_trans_callback(event, status, path, start_time, cur_size, total_size):
        msg = {
            'code': status['code'],
            'msg': status['msg'],
            'values': {'path': path, 'start_time': start_time, 'cur_size': cur_size, 'total_size': total_size}
        }

        cb_input = {'module': input["_module"], 'event': event, 'msg': msg}

        return json_lpc.invoke_callback(cb_input, input)
    return __file_trans_callback


def file_is_need_sync(rpc, svc, local_path, remote_path, callback):
    c_remote = remote_path
    file_path = Arg(U8 | ARRAY, bytearray(c_remote + '\0', encoding="utf8"))
    crc32 = Arg(U8 | ARRAY | EDITABLE, list(range(4)))
    try:
        result = rpc.exec_ffi_func(1, "calc_file_crc32", [file_path, crc32], need_ack=False,
                                   need_rsp=True, timeout=60)
    except Exception as e:
        logger.error(e)
        return FAIL_FLAG

    if result.signed() == -10:
        # 远端文件不存在， 拉取文件时跳过报错，推送文件时需要同步
        logger.debug("file: {} not exits, result: {}".format(remote_path, result.signed()))
        try:
            return REMOTE_FILE_NOT_FOUND_FLAG
        except Exception as e:
            logger.error(e)
            return FAIL_FLAG
    elif result.signed() == -5:
        logger.warning("check CRC failed. device alloc memory failed")
        # 设备端申请内存失败
        return FAIL_FLAG
    else:
        remote_crc32 = 0
        # 获取 CRC32 成功，进行对比
        for val in crc32.value[0:4]:
            remote_crc32 = (remote_crc32 << 8) + val
        local_file_path = Path(local_path)
        if not local_file_path.exists():
            # 拉取文件时，本地文件不存在，需要同步
            return LOCAL_FILE_NOT_FOUND_FLAG
        with open(local_path, "rb") as f:
            local_file = f.read()
        # 计算本地文件 CRC 值
        local_crc32 = calculate_crc32(local_file)
        if local_crc32 == remote_crc32:
            # CRC 值相同，跳过
            return SKIP_FLAG
        else:
            # CRC 值不同，需要同步
            return SYNC_FLAG
