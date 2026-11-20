# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-05-19     armink       the first version
#

import json
import traceback

import global_var
from urpc.src.ffi import *
from wearable import json_lpc

LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.time'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def time_sync_ffi(input):
    try:
        rpc = global_var.get('rpc')
        timestamp = Arg(U32, input['timestamp'])
        timezone = Arg(U32, input['timezone'])
        # 执行远端 ffi 函数
        result = rpc.exec_ffi_func(1, "time_sync", [timestamp, timezone], need_ack=False, need_rsp=True, timeout=2, retry = 0)
        return json_lpc.gen_success_output_json()
    except Exception as e:
        logger.error(traceback.format_exc())
        return json_lpc.gen_failed_output_json(e)

def time_sync_svc(input):
    try:
        rpc = global_var.get('rpc')
        if "minute_offset" in input:
            offset = input['minute_offset']
        else:
            offset = 0
        input = {"timestamp": input['timestamp'], "timezone": input['timezone'], "minute_offset": offset}
        input = bytearray(json.dumps(input), encoding="utf8")
        # 执行远端 svc 函数
        result = rpc.exec_svc(1, "time_sync_svc", input, need_ack=False, need_rsp=True, timeout=2)
        return json_lpc.gen_success_output_json()
    except Exception as e:
        logger.error(traceback.format_exc())
        return json_lpc.gen_failed_output_json(e)

def service_time_sync(input):
    try:
        rpc = global_var.get('rpc')
        if rpc.compare_version("2.4.0") > 0:
            logger.info("Current version is later than 2.4.0, use the <time_sync_svc> interface.")
            return time_sync_svc(input)
        else:
            logger.info("Current version is earlier than 2.4.0, use the <time_sync> interface.")
            return time_sync_ffi(input)
    except Exception as e:
        logger.error(traceback.format_exc())
        return json_lpc.gen_failed_output_json(e)

def service_device_info(input):
    rpc = global_var.get('rpc')
    # 手表侧的 RPC 的 input 需要 bytearray 类型，其出参也是 bytearray
    values = rpc.exec_svc(1, "device_info", bytearray(), need_ack=False,
                          need_rsp=True, timeout=3)
    # 生成返回结果
    output = json_lpc.gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output
