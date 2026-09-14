# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2023-05-28     armink       the first version
#

import logging

import global_var
import ubjson
from wearable import json_lpc
from wearable.json_lpc import gen_success_output_json, gen_failed_output_json

LOG_LVL = logging.INFO
LOG_TAG = 'svc.tsdb'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


# 查询 TSDB 记录数量
def service_tsdb_query_count(input):
    rpc = global_var.get('rpc')
    rpc_input = ubjson.dumpb(input)
    rpc_output = rpc.exec_svc(1, "tsdb_query_count", rpc_input, need_ack=False, need_rsp=True, timeout=3)
    # 生成返回结果
    dict_output = ubjson.loadb(rpc_output)
    rpc_result = dict_output.pop('result')
    if rpc_result == 0:
        output = gen_success_output_json()
    else:
        output = gen_failed_output_json('tsdb file was NOT found')
    output["values"] = dict_output
    return output


# 查询 TSDB 记录
def service_tsdb_query(input):
    rpc = global_var.get('rpc')
    total_records = []

    while True:
        rpc_input = ubjson.dumpb(input)
        rpc_output = rpc.exec_svc(1, "tsdb_query", rpc_input, need_ack=False, need_rsp=True, timeout=3)
        dict_output = ubjson.loadb(rpc_output)
        dict_output['path'] = input['path']
        logger.debug("tsdb_query, input: %s, output: %s", str(input), str(dict_output))
        # 剔除不需要暴露给应用层的数据
        buf_is_full = dict_output.pop('buf_is_full')
        # 执行 onProgress callback
        cb_input = {'module': input["_module"], 'event': "onProcess",
                    'msg': {'code': 200, 'msg': 'success', 'values': dict_output}}
        if json_lpc.invoke_callback(cb_input, input) is True:
            logger.info("user interrupt callback quit initiative.")
            break
        # 转存每次查询到结果
        if 'records' in dict_output:
            records = dict_output.pop('records')
            for record in records:
                total_records.append(record)

        # 获取下次循环的检查条件
        rpc_result = dict_output.pop('result')
        if buf_is_full is True:
            # 重新计算获取索引
            input['index'] = input['index'] + dict_output['count']
            if input['count'] != -1 and input['count'] > dict_output['count']:
                input['count'] = input['count'] - dict_output['count']
        elif rpc_result != 0 or buf_is_full is False:
            # 检查退出的条件
            break

    dict_output = dict()
    dict_output['records'] = total_records
    dict_output['count'] = len(total_records)
    dict_output['path'] = input['path']
    logger.debug('tsdb_query total output: %s', dict_output)

    if rpc_result == 0:
        cb_input = {'module': input["_module"], 'event': 'onSuccess',
                    'msg': {'code': 200, 'msg': 'success', 'values': dict_output}}
        json_lpc.invoke_callback(cb_input, input)
        output = gen_success_output_json()
    else:
        cb_input = {'module': input["_module"], 'event': 'onFailed',
                    'msg': {'code': 500, 'msg': 'tsdb file was NOT found', 'values': dict_output}}
        json_lpc.invoke_callback(cb_input, input)
        output = gen_failed_output_json('tsdb file was NOT found')
    output["values"] = dict_output

    cb_input = {'module': input["_module"], 'event': 'onComplete',
                'msg': {'code': 200, 'msg': 'complete', 'values': dict_output}}
    json_lpc.invoke_callback(cb_input, input)

    return output
