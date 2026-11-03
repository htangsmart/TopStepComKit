# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-05-09     armink       the first version
#

import json


import global_var
from urpc.src.ffi import *
from wearable.json_lpc import gen_success_output_json

LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.dcm'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


# 从手表读取 DCM 数据
def service_dcm_get(input):
    rpc = global_var.get('rpc')
    # 手表侧的 RPC 的 input 需要 bytearray 类型，其出参也是 bytearray
    values = rpc.exec_svc(1, "svc_dcm_get", bytearray(json.dumps(input), encoding="utf8"), need_ack=False,
                          need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output


# 往手表 DCM 设置数据
def service_dcm_set(input):
    rpc = global_var.get('rpc')
    # 手表侧的 RPC 的 input 需要 bytearray 类型，其出参也是 bytearray
    # TODO 后期考虑出参问题
    rpc.exec_svc(1, "svc_dcm_set", bytearray(json.dumps(input), encoding="utf8"), need_ack=False,
                          need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    return output
