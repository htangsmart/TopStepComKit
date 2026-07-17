# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# JSON LPC call for application
#
# Change Logs:
# Date           Author       Notes
# 2021-05-09     armink       the first version
#


import json
import logging
import threading
import traceback
import global_var

from urpc.src.urpc_utils import *

LOG_LVL = logging.DEBUG
LOG_TAG = 'persimwear.jsonsvc'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

"""
注册 svc 服务，默认单例且等待模式运行， 单例模式下，多次执行同一个 svc 服务，需要等到前面的执行完成之后才能执行后面的 svc 服务，
不同 svc 服务之间不受影响。

如果需要使用多实例模式运行，需要确保设备能够有足够算力并且不会造成未知异常（例如： 文件同时读写等）
"""
def register_svc(svc, ver=0, singleton=True, blocking=True):
    if not global_var.has('svc_table'):
        svc_table = {}
        global_var.set('svc_table', svc_table)
    else:
        svc_table = global_var.get('svc_table')
    # 检查服务是否已经存在，并注册服务
    if svc.__name__ in svc_table:
        svc_table[svc.__name__][ver] = svc
    else:
        svc_lock = None
        if singleton:
            # 创建锁并添加到 svc_info 中
            svc_lock = threading.Lock()
        svc_info = {ver:svc, 'lock': svc_lock, 'blocking': blocking}
        svc_table[svc.__name__] = svc_info
    logger.debug("json LPC (%s@V%s) register success", svc.__name__, str(ver))

def __release_svc_lock(svc_lock=None):
    if svc_lock is not None:
        svc_lock.release()

def __exec_svc_helper(name, input, ver=0):
    svc_table = global_var.get('svc_table')
    logger.debug("exec service: %s, input: %s", name, input)
    if len(input) > 0:
        return svc_table[name][ver](json.loads(input))
    else:
        return svc_table[name][ver](json.loads("{}"))


def __invoke_failed_callback(input, msg, code):
    input = json.loads(input)
    if '_eventId' in input:
        cb_input = {'module': input['_module'], 'event': 'onFailed', 'msg': {'code': code, 'msg': msg, 'values': ''}}
        invoke_callback(cb_input, input)
        cb_input = {'module': input['_module'], 'event': 'onComplete', 'msg': {'code': code, 'msg': msg, 'values': ''}}
        invoke_callback(cb_input, input)


def exec_svc(name, input, ver=0):
    svc_table = global_var.get('svc_table')
    if svc_table and name in svc_table:
        svc_lock = svc_table[name]['lock']
        svc_lock_blocking = svc_table[name]['blocking']
        try:
            # 是否存在 lock 对象，存在 lock 对象时，只允许一个实例运行
            if svc_lock is not None:
                # svc_lock_blocking 表示是否等待获取锁
                has_lock = svc_table[name]['lock'].acquire(blocking=svc_lock_blocking)
                if not has_lock:
                    # 没有获取到锁，判定为有实例在运行，返回错误
                    logger.debug("Parallel execution not allowed {}".format(name))
                    __invoke_failed_callback(input, "Parallel execution not allowed", 500)
                    return json.dumps(gen_failed_output_json("Parallel execution not allowed", 503))
                output = __exec_svc_helper(name, input, ver)
            else:
                output = __exec_svc_helper(name, input, ver)
            # 释放锁
            __release_svc_lock(svc_lock)
            if isinstance(output, bytes):
                return json.dumps(json.loads(str(output, encoding='utf8')))
            return json.dumps(output)
        except UrpcTimeoutException as e:
            __invoke_failed_callback(input, "Request Timeout", 408)
            __release_svc_lock(svc_lock)
            return json.dumps(gen_failed_output_json("Request Timeout", 408))
        except UrpcSvcNotFoundException as e:
            __invoke_failed_callback(input, "Service Not Found", 404)
            __release_svc_lock(svc_lock)
            return json.dumps(gen_failed_output_json("Service Not Found", 404))
        except UrpcDisconnectException as e:
            __invoke_failed_callback(input, "Service Disconnect", 502)
            __release_svc_lock(svc_lock)
            return json.dumps(gen_failed_output_json("Service Disconnect", 502))
        except Exception as e:
            logger.error(traceback.format_exc())
            __invoke_failed_callback(input, "Unknown Error: " + e.__str__(), 501)
            __release_svc_lock(svc_lock)
            return json.dumps(gen_failed_output_json("Unknown Error: " + e.__str__(), 501))
    else:
        logger.warning("json LPC (%s@V%s) service not found", name, str(ver))
        return json.dumps(gen_failed_output_json('Service Not Found', 404))

def set_callback(callback):
    lock = threading.Lock()
    global_var.set('svc_callback', callback)
    global_var.set('svc_callback_lock', lock)

def off_callback(type):
    if global_var.has(type):
        global_var.remove(type)
        return True
    else:
        return False

def invoke_callback(cb_data, lpc_input = {}):
    callback = global_var.get('svc_callback')
    lock = global_var.get('svc_callback_lock')
    if callback is not None:
        # 统一回调的格式， 共三个参数
        # module 回调所属模块
        # event 回调事件类型
        # msg 回调信息， 与其他接口的返回值格式保持一致
            # 回调信息格式为一个字典， 包含 code msg values 三个属性
            # code 表示状态码
            # msg 表示成功或者错误描述信息
            # values 为成功时的数据

        assert 'module' in cb_data
        assert 'event' in cb_data
        assert 'msg' in cb_data
        assert isinstance(cb_data['msg'], dict)
        assert 'code' in cb_data['msg']
        assert 'msg' in cb_data['msg']
        assert 'values' in cb_data['msg']

        msg = dict()
        if "_eventId" in lpc_input:
            msg["_eventId"] = lpc_input["_eventId"]
        else:
            msg["_eventId"] = ""
        msg["_content"] = cb_data["msg"]
        lock.acquire()
        output = callback(str(cb_data['module']), str(cb_data['event']), json.dumps(msg))
        lock.release()
        return output
    else:
        logger.error("not found svc_callback")


def gen_success_output_json():
    return {'code': 200, 'msg': 'success', 'values': ''}


def gen_failed_output_json(err_msg, code=500):
    try:
        if not isinstance(err_msg, str):
            msg = json.dumps(err_msg) # 尝试序列化，如果可以序列化，则直接返回，否则会进入异常捕获
        return {'code': code, 'msg': err_msg, 'values': '' }
    except Exception as e:
        # err_msg 可能无法被序列化，转换成字符串
        if not isinstance(err_msg, str):
            err_msg = err_msg.__str__()
        return {'code': code, 'msg': err_msg, 'values': '' }