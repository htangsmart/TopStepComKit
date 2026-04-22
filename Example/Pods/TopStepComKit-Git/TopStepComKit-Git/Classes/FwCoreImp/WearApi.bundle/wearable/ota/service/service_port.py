# -*- coding: utf-8 -*-

import traceback
import os
import json

import global_var
from urpc.src.ffi import *
from wearable import json_lpc
from wearable.json_lpc import gen_success_output_json, gen_failed_output_json
from wearable.ota.main import ota_main, ota_quit
from wearable.ota.utils import ota_get_package_require_reboot

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.service_port'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


# 从手表获取当前版本信息状态
def service_ota_get_version(param=None):
    rpc = global_var.get('rpc')
    # 手表侧的 RPC 的 input 需要 bytearray 类型，其出参也是 bytearray
    values = rpc.exec_svc(1, "svc_ota_get_version", need_ack=False, need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output

# 进入升级模式
def service_ota_set_upgrade_state(param):
    rpc = global_var.get('rpc')
    # 查询是否要求重启
    res = ota_get_package_require_reboot(str(param["local"]))
    if res is True:
        values = rpc.exec_ffi_func(1, "svc_ota_set_upgrade_state", need_ack=False, need_rsp=True, timeout=3)
    else:
        values = rpc.exec_ffi_func(1, "svc_ota_set_upgrade_choke", need_ack=False, need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = values.signed()
    return output


# 获取升级状态
def service_ota_get_upgrade_state(param=None):
    rpc = global_var.get('rpc')
    values = rpc.exec_ffi_func(1, "svc_ota_get_upgrade_state", need_ack=False, need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = values.signed()
    return output


# 上报信息给手机
def service_ota_upgrade_message_report(event, message):
    result = json_lpc.invoke_callback({'module': 'wear.ota.process', 'event': event, 'msg': message})
    return result


# 开始升级
def service_ota_update(param):
    try:
        logger.info('service_ota_update run...')
        package_path = str(param["local"])
        retry = int(param["retry"])
        logger.info('OTA local upgrade package path: %s' % package_path)
        ota_main(package_path, retry=retry)
        logger.info('service_ota_update end')
        output = gen_success_output_json()
        return output
    except Exception as ex:
        logger.error(ex)
        logger.error(traceback.format_exc())
        return gen_failed_output_json(ex.__str__())


# 退出升级
def service_ota_quit(param):
    try:
        logger.info('service_ota_quit run...')
        ota_quit()
        logger.info('service_ota_quit end')
        output = gen_success_output_json()
        return output
    except Exception as ex:
        logger.error(ex)
        logger.error(traceback.format_exc())
        return gen_failed_output_json(ex.__str__())

