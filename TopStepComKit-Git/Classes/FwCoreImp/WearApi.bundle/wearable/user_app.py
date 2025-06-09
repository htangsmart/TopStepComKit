# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-06-23     yuanjie       the first version
#
import threading
import time
import json
import ubjson
import base64
import traceback

from urpc.src.urpc_utils import *
from wearable.json_lpc import gen_failed_output_json

from wearable import json_lpc
from wearable.files.push import push
from wearable.files.utils import remove

import global_var
from urpc.src.ffi import *
from wearable.json_lpc import gen_success_output_json
from utils.code import CODE_APP

LOG_LVL = logging.INFO
LOG_TAG = 'wearable.user_app'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

APP_SEND_MSG_FAILED             = 204
APP_SEND_MSG_SUCCESS            = 205
APP_SEND_DATA_CHANNEL_FAILED    = 208
APP_SEND_DATA_CHANNEL_SUCCESS   = 209

INSTALL_STATUS_CODE_TABLE = {
    0: {"code": 200, "msg": 'success', "values": ""},
    1: {"code": CODE_APP + 1, "msg": "The package was not found", "values": ""},
    2: {"code": CODE_APP + 2, "msg": "The package is not valid", "values": ""},
    3: {"code": CODE_APP + 3, "msg": "The package info load failed", "values": ""},
    4: {"code": CODE_APP + 4, "msg": "The package temporary directory make failed", "values": ""},
    5: {"code": CODE_APP + 5, "msg": "The package copy failed", "values": ""},
    6: {"code": CODE_APP + 6, "msg": "The package copy is not valid", "values": ""},
    7: {"code": CODE_APP + 7, "msg": "The package extract json failed", "values": ""},
    8: {"code": CODE_APP + 8, "msg": "The app old uninstall failed", "values": ""},
    9: {"code": CODE_APP + 8, "msg": "The app resource file deployment failed", "values": ""},
    10: {"code": CODE_APP + 10, "msg": "The app info load failed", "values": ""},
    11: {"code": CODE_APP + 11, "msg": "The app data store directory creation failed", "values": ""},
    12: {"code": CODE_APP + 12, "msg": "The app list update failed", "values": ""},
    101: {"code": CODE_APP + 13, "msg": "No memory", "values": ""},
    102: {"code": CODE_APP + 14, "msg": "Permission exception", "values": ""},
    103: {"code": CODE_APP + 15, "msg": "Unknown error", "values": ""}
}


def __app_install__(input):
    rpc = global_var.get('rpc')
    remote_path = input['remote_path']
    is_launch = input['launch']
    app_id = Arg(U8 | ARRAY, bytearray(remote_path + '\0', encoding="utf8"))
    launch = Arg(U32, int(is_launch))
    msg = {}
    # 执行远端 ffi 函数
    try:
        result = rpc.exec_ffi_func(1, "user_app_install",
                                [app_id, launch], need_ack=False, need_rsp=True, timeout=30)
        if result.value in INSTALL_STATUS_CODE_TABLE:
            value = result.value
        else:
            value = 103
        msg = INSTALL_STATUS_CODE_TABLE[value]
        msg['values'] = {'path': remote_path}
        if result.value == 0:
            cb_data = {'module': input["_module"], 'event': "onInstallSuccess", 'msg': msg}
            remove(remote_path)
            json_lpc.invoke_callback(cb_data, input)
            return
    except UrpcTimeoutException as e:
        msg["code"] = 408
        msg["msg"] = 'app install timeout'
    except UrpcSvcNotFoundException as e:
        msg["code"] = 404
        msg["msg"] = 'svc service not found'
    except Exception as e:
        msg["code"] = 500
        msg["msg"] = e.__str__()
    # 安装失败
    msg['values'] = {'path': remote_path}
    cb_data = {'module': input["_module"], 'event': "onInstallFailed", 'msg': msg}
    remove(remote_path)
    json_lpc.invoke_callback(cb_data, input)
    

def service_user_app_install(input):
    local_path = input['local_path']
    remote_path = input['remote_path']
    is_launch = input['launch']

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
                    __app_install__(input)
            if(event == 'onSuccess'):
                file_push_success = True
                
        # 调用底层文件推送方法
        push(local_path, remote_path, False, continue_write=True, callback=__file_progress_cb)
    __push_file__(local_path, remote_path)
    return json_lpc.gen_success_output_json()


def service_user_app_uninstall(input):
    rpc = global_var.get('rpc')
    app_id = Arg(U8 | ARRAY, bytearray(input['id'] + '\0', encoding="utf8"))
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "user_app_uninstall",
                               [app_id], need_ack=False, need_rsp=True, timeout=10)
    if result.value in INSTALL_STATUS_CODE_TABLE:
        value = result.value
    else:
        value = 103

    return INSTALL_STATUS_CODE_TABLE[value]


def service_user_app_info(input):
    rpc = global_var.get('rpc')
    # 手表侧的 RPC 的 input 需要 bytearray 类型，其出参也是 bytearray
    values = rpc.exec_svc(1, "svc_user_app_installed_info", bytearray(), need_ack=False,
                          need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output


def service_app_launch(input):
    rpc = global_var.get('rpc')
    uri = Arg(U8 | ARRAY, bytearray(input['uri'] + '\0', encoding="utf8"))
    result = rpc.exec_ffi_func(1, "app_launch", [uri], need_ack=False, need_rsp=True, timeout=10)
    # 生成返回结果
    # TODO 目前 0 为拉起失败， 1 成功，后面统一改成 0 成功 其他为失败
    if result.value == 1:
        output = gen_success_output_json()
        output['values'] = 1
    else:
        output = gen_failed_output_json("launch app failed")
    return output


def service_app_msg_recv_json(input):
    rpc = global_var.get('rpc')
    block_size = rpc.block_size - 48
    msg_len = len(input['msg'].encode("utf-8"))
    logger.debug("recv msg: {}".format(input))
    offset = 0
    count = msg_len
    input_msg = dict()
    input_msg['app'] = input['app']
    input_msg['total'] = msg_len
    input_msg['msg'] = ''
    input_msg['index'] = 0
    input_msg['timestamp'] = int(round((time.time() * 1000)))
    logger.debug("msg total len = {}".format(msg_len))
    while count > 0:
        # msg is too long
        if count > block_size - 108:
            send_len = block_size  - 108
        else:
            send_len = count
        send_msg = input['msg'][offset:send_len+offset]
        count -= send_len
        offset += send_len
        input_msg['msg'] = send_msg
        input_msg['index'] += send_len
        logger.debug("send msg: {}".format(input_msg))

        package_msg = dict()
        package_msg['from'] = 'phone'
        package_msg['to'] = input['app']

        body = dict()
        body['tag'] = 'message'
        body['content'] = input_msg

        package_msg['body'] = body
        send_buf = Arg(U8 | ARRAY, bytearray(json.dumps(package_msg) + '\0', encoding="utf8"))
        buffer_len = Arg(U32, send_buf.value_len)
        result = rpc.exec_ffi_func(1, "msg_recv", [send_buf, buffer_len], need_ack=False,
                                   need_rsp=True, timeout=3)
        # cellphone app send msg failed
        if result.value != APP_SEND_MSG_SUCCESS:
            result.value = APP_SEND_MSG_FAILED
            break

    output = gen_success_output_json()
    output['values'] = result.value
    return output


def service_app_msg_recv_ubjson(input):
    rpc = global_var.get('rpc')
    block_size = rpc.block_size - 196
    msg_buf = bytearray(input['msg'], encoding="utf8")
    msg_len = len(msg_buf)
    logger.info("service_app_msg_recv_ubjson msg: {}".format(msg_buf))
    offset = 0
    count = msg_len
    input_msg = dict()
    input_msg['app'] = input['app']
    input_msg['total'] = msg_len
    input_msg['msg'] = ''
    input_msg['index'] = 0
    input_msg['timestamp'] = int(round((time.time() * 1000)))
    logger.info("service_app_msg_recv_ubjson total len = {}".format(msg_len))
    value = APP_SEND_MSG_SUCCESS
    while count > 0:
        # msg is too long
        if count > block_size:
            send_len = block_size
        else:
            send_len = count
        send_msg = msg_buf[offset:send_len+offset]
        count -= send_len
        offset += send_len
        input_msg['msg'] = send_msg
        input_msg['index'] += send_len
        logger.info("send msg: {}".format(input_msg))

        package_msg = dict()
        package_msg['from'] = 'phone'
        package_msg['to'] = input['app']

        body = dict()
        body['tag'] = 'message'
        body['content'] = input_msg

        package_msg['body'] = body
        result = rpc.exec_svc(1, "msg_recv_ubjson", ubjson.dumpb(package_msg), need_ack=False, need_rsp=True, timeout=3)
        # cellphone app send msg failed
        if result[1] != APP_SEND_MSG_SUCCESS:
            value = APP_SEND_MSG_FAILED
            break

    output = gen_success_output_json()
    output['values'] = value
    return output


def service_app_msg_recv(input):
    try:
        rpc = global_var.get('rpc')
        if rpc.compare_version("2.4.2") > 0:
            return service_app_msg_recv_ubjson(input)
        else:
            return service_app_msg_recv_json(input)
    except Exception as e:
        logger.error(traceback.format_exc())
        return json_lpc.gen_failed_output_json(e)


def service_app_data_channel_send(input):
    rpc = global_var.get('rpc')
    # 判断底层固件是否支持此接口，如果不支持直接返回失败
    if rpc.compare_version("2.4.1") <= 0:
        output = json_lpc.gen_failed_output_json("No Support")
        output['values'] = APP_SEND_DATA_CHANNEL_FAILED
        return output
    # 如果固件支持此接口，则继续执行
    block_size = rpc.block_size - 196
    channel = int(input['channel'])
    # buffer 从 base64字符串还原为 ByteArray
    buffer = base64.b64decode(input['buffer'])
    # 消息数据转为 ubjson类型，方便传输
    msg_obj = ubjson.dumpb({'channel': channel, 'buffer': buffer})
    msg_len = len(msg_obj)
    offset = 0
    count = msg_len
    input_msg = dict()
    input_msg['app'] = 'Phone'
    input_msg['total'] = msg_len
    input_msg['msg'] = ''
    input_msg['index'] = 0
    input_msg['timestamp'] = int(round((time.time() * 1000)))
    value = APP_SEND_DATA_CHANNEL_SUCCESS
    while count > 0:
        if count > block_size:
            send_len = block_size
        else:
            send_len = count

        send_msg = msg_obj[offset:send_len+offset]
        count -= send_len
        offset += send_len
        input_msg['msg'] = send_msg
        input_msg['index'] += send_len

        package_msg = dict()
        package_msg['from'] = 'phone'
        package_msg['to'] = 'local.control'

        body = dict()
        body['tag'] = 'dataChannel'
        body['content'] = input_msg

        package_msg['body'] = body
        result = rpc.exec_svc(1, "msg_recv_ubjson", ubjson.dumpb(package_msg), need_ack=False, need_rsp=True, timeout=3)
        # cellphone app send msg failed
        if result[1] != APP_SEND_MSG_SUCCESS:
            value = APP_SEND_DATA_CHANNEL_FAILED
            break

    output = gen_success_output_json()
    output['values'] = value
    return output


def service_app_ping(input):
    rpc = global_var.get('rpc')
    package_msg = dict()
    package_msg['from'] = 'phone'
    package_msg['to'] = 'local.control'

    msg_len = len("".encode("utf-8"))
    body = dict()
    body['tag'] = 'ping'
    body['content'] = {
        'app': input['app'],
        'total': msg_len,
        'msg': "",
        'index': msg_len,
        'timestamp': int(round((time.time() * 1000 % 10000000)))
    }

    package_msg['body'] = body
    uri = Arg(U8 | ARRAY, bytearray(json.dumps(package_msg) + '\0', encoding="utf8"))
    buffer_len = Arg(U32, uri.value_len)
    result = rpc.exec_ffi_func(1, "msg_recv", [uri, buffer_len], need_ack=False, need_rsp=True, timeout=3)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = result.value
    return output


def service_app_installed(input):
    input['msg'] = ""
    rpc = global_var.get('rpc')
    package_msg = dict()
    package_msg['from'] = 'phone'
    package_msg['to'] = 'local.control'

    msg_len = len(input['msg'].encode("utf-8"))
    body = dict()
    body['tag'] = 'appIsInstalled'
    body['content'] = {
        'app': input['app'],
        'total': msg_len,
        'msg': input['msg'],
        'index': msg_len,
        'timestamp': int(round((time.time() * 1000 % 10000000)))
    }

    package_msg['body'] = body
    uri = Arg(U8 | ARRAY, bytearray(json.dumps(package_msg) + '\0', encoding="utf8"))
    buffer_len = Arg(U32, uri.value_len)
    result = rpc.exec_ffi_func(1, "msg_recv", [uri, buffer_len], need_ack=False, need_rsp=True, timeout=10)
    # 生成返回结果
    output = gen_success_output_json()
    output["values"] = result.value
    return output

