# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-05-14     armink       the first version
#
import json
import threading
from wearable.files.utils import remove
import ubjson
from urpc.src.urpc_utils import *
from wearable.files.push import push
import global_var

from urpc.src.ffi import *
from wearable import json_lpc
from wearable.json_lpc import gen_success_output_json, gen_failed_output_json
from utils.code import CODE_DIAL 


APPLY_STATUS_CODE_TABLE = {
    0: {"code": 200, "msg": "success", "values": ""},
    1: {"code": CODE_DIAL + 21, "msg": "Invalid dial id", "values": ""},
    2: {"code": CODE_DIAL + 22, "msg": "The installed dials information is incorrect", "values": ""},
    3: {"code": CODE_DIAL + 23, "msg": "The apply dial state is hide, not allow apply", "values": ""},
    103: {"code": CODE_DIAL + 24, "msg": "Apply unknown", "values": ""}
}


INSTALL_STATUS_CODE_TABLE = {
    # 安装相关错误
    0: {"code": 200, "msg": "success", "values": ""},
    1: {"code": CODE_DIAL + 1, "msg": "Invalid dial id", "values": ""},
    2: {"code": CODE_DIAL + 2, "msg": "The dial resource path is incorrect", "values": ""},
    3: {"code": CODE_DIAL + 3, "msg": "The number of installed dial faces has reached the upper limit", "values": ""},
    4: {"code": CODE_DIAL + 4, "msg": "The dial JSON information is incorrect", "values": ""},
    5: {"code": CODE_DIAL + 5, "msg": "The installation dial is busy", "values": ""},
    6: {"code": CODE_DIAL + 6, "msg": "Invalid dial alias", "values": ""},
    103: {"code": CODE_DIAL + 7, "msg": "Install unknown", "values": ""},
}


UNINSTALL_STATUS_CODE_TABLE = {
    0: {"code": 200, "msg": "success", "values": ""},
    1: {"code": CODE_DIAL + 41, "msg": "Invalid dial id ", "values": ""},
    2: {"code": CODE_DIAL + 42, "msg": "The installed dials information is incorrect", "values": ""},
    103: {"code": CODE_DIAL + 43, "msg": "uninstall unknown", "values": ""}
}


def __dial_install__(input):
    rpc = global_var.get('rpc')
    remote_path = input['remote_path']
    alias = input['alias']

    dial_path = Arg(U8 | ARRAY, bytearray(remote_path + '\0', encoding="utf8"))
    dial_alias = Arg(U8 | ARRAY, bytearray(alias + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    msg = {}

    try:
        result = rpc.exec_ffi_func(1, "svc_dial_install",
                               [dial_path, dial_alias], need_ack=False, need_rsp=True, timeout=30)
        
        msg = INSTALL_STATUS_CODE_TABLE[result.value]
        msg['values'] = {'path': remote_path}
        if(result.value == 0):
            cb_data = {'module': input["_module"], 'event': "onInstallSuccess", 'msg': msg}
            remove(remote_path)
            json_lpc.invoke_callback(cb_data, input)
            return
    except UrpcTimeoutException as e:
        msg["code"] = 500
        msg["msg"] = 'app install timeout'
    except UrpcSvcNotFoundException as e:
        msg["code"] = 404
        msg["msg"] = 'svc service not found'
    except Exception as e:
        msg["code"] = 500
        msg["msg"] = e.__str__()
    msg['values'] = {'path': remote_path}
    
    cb_data = {'module': input["_module"], 'event': "onInstallFailed", 'msg': msg}
    remove(remote_path)
    json_lpc.invoke_callback(cb_data, input)

def service_dial_install(input):
    local_path = input['local_path']
    remote_path = input['remote_path']

    # 开始推送文件
    def __push_file__(local_path, remote_path):

        file_push_success = False

        # 文件推送进度回调
        def __file_progress_cb(event, status, path, file_start_time, cur_size, total_size):
            nonlocal file_push_success
            msg = {'code': status['code'], 'msg': status['msg'], 'values': {'path': path, 'start_time': file_start_time, 'cur_size': cur_size, 'total_size': total_size}}
            cb_data = {'module': input["_module"], 'event': event, 'msg': msg}
            json_lpc.invoke_callback(cb_data, input)
            if(event == 'onComplete'):
                if file_push_success:
                    # 文件传输成功，安装应用
                    msg = {'code': 200, 'msg': 'success', 'values': {'path': path}}
                    cb_data = {'module': input["_module"], 'event': "onInstalling", 'msg': msg}
                    json_lpc.invoke_callback(cb_data, input)
                    __dial_install__(input)
            if(event == 'onSuccess'):
                file_push_success = True
        # 调用底层文件推送方法
        push(local_path, remote_path, False, continue_write=True, callback=__file_progress_cb)
    __push_file__(local_path, remote_path)
    return json_lpc.gen_success_output_json()


def service_dial_uninstall(input):
    rpc = global_var.get('rpc')
    dial_id = Arg(U8 | ARRAY, bytearray(input['id'] + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "svc_dial_uninstall",
                               [dial_id], need_ack=False, need_rsp=True, timeout=10)
    
    if result.value in UNINSTALL_STATUS_CODE_TABLE:
        value = result.value
    else:
        value = 103
    return UNINSTALL_STATUS_CODE_TABLE[value]


def service_dial_apply(input):
    rpc = global_var.get('rpc')
    dial_id = Arg(U8 | ARRAY, bytearray(input['id'] + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "svc_dial_apply",
                               [dial_id], need_ack=False, need_rsp=True, timeout=10)
    if result.value in APPLY_STATUS_CODE_TABLE:
        value = result.value
    else:
        value = 103
    return APPLY_STATUS_CODE_TABLE[value]
    


# 从手表读取当前表盘id
def service_dial_get_current(input):
    rpc = global_var.get('rpc')
    values = rpc.exec_svc(1, "svc_dial_get_current", bytearray(), need_ack=False,
                          need_rsp=True, timeout=10)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = values.decode('utf-8')
    return output


# 从手表读取所有表盘id
def service_dial_info(input):
    rpc = global_var.get('rpc')
    values = rpc.exec_svc(1, "svc_dial_info", bytearray(), need_ack=False,
                          need_rsp=True, timeout=10)
    # 生成返回结果
    output = gen_success_output_json()
    try:
        output["values"] = json.loads(str(values, encoding='utf-8'))
    except Exception as e:
        output["values"] = json.loads(ubjson.loadb(values))
    return output


def service_dial_hide(input):
    rpc = global_var.get('rpc')
    dial_id = Arg(U8 | ARRAY, bytearray(input['id'] + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "svc_dial_hide",
                               [dial_id], need_ack=False, need_rsp=True, timeout=10)
    if result.value == 0:
        output = gen_success_output_json()
    else:
        output = APPLY_STATUS_CODE_TABLE[result.value]
    return output


def service_dial_unhide(input):
    rpc = global_var.get('rpc')
    dial_id = Arg(U8 | ARRAY, bytearray(input['id'] + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "svc_dial_unhide",
                               [dial_id], need_ack=False, need_rsp=True, timeout=10)
    if result.value == 0:
        output = gen_success_output_json()
    else:
        output = APPLY_STATUS_CODE_TABLE[result.value]
    return output


def service_set_dial_order_info(input):
    rpc = global_var.get('rpc')
    dials = Arg(U8 | ARRAY, bytearray(json.dumps(input['dials']) + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "svc_set_dial_order_info",
                               [dials], need_ack=False, need_rsp=True, timeout=10)
    if result.value == 0:
        output = gen_success_output_json()
    else:
        output = APPLY_STATUS_CODE_TABLE[result.value]
    return output

