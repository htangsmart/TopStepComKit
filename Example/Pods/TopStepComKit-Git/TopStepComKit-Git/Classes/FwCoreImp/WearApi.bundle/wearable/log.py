import zipfile
import os
import json
import logging
from pathlib import Path

from urpc.src.urpc_utils import UrpcSvcNotFoundException
from wearable import json_lpc
from datetime import datetime
import global_var
from urpc.services.file import FileSvc
from wearable.files.pull import pull

import time
import threading
from utils.code import CODE_LOG

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.log'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

LOG_ARCHIVE_CODE_TABLE = {
    0: {"code": 200, "msg": "success", 'values': ''},
    1: {"code": CODE_LOG + 20, "msg": "Unknow error", 'values': ''},
    3: {"code": CODE_LOG + 3, "msg": "Not enough storage space", 'values': ''} ,
    4: {"code": CODE_LOG + 4, "msg": "No log file", 'values': ''} ,
    5: {"code": CODE_LOG + 5, "msg": "No memory", 'values': ''} ,
    7: {"code": CODE_LOG + 7, "msg": "Only one is allowed", 'values': ''},
    8: {"code": CODE_LOG + 8, "msg": "Get log size failed", 'values': ''}
}

def generate_result(code, msg, values = ''):
    return {'code': code, 'msg': msg, 'values': values}

# 文件传输进度回调中 event 和 log 拉取 event 映射表

_log_file_event_map = {
    "onProcess": "onExportLogProcess",
    "onFailed": "onExportLogFailed"
}

def __get_output_path(input, type="device"):
    # 获取当前时间
    _time = time.strftime("%Y-%m-%d_%H%M%S", time.localtime())

    # 拼接日志压缩包文件存储路径
    if "file_path" in input:
        try:
            if not os.path.exists(input["file_path"]):
                os.makedirs(input["file_path"], exist_ok=True)
            _log_output_path = input["file_path"] + "/PersimOS_log_{}.zip".format(_time)
        except Exception as e:
            raise e
    else:
        _log_output_path = os.environ["WEARSERVICE_LOG_PATH"] + "/../../PersimOS_{}_log_{}.zip".format(type, _time)

    # 删除旧的压缩包
    if os.path.exists(_log_output_path):
        os.remove(_log_output_path)

    return _log_output_path


def invoke_result_callback(input, event, msg):
    cb_input = {'module': input["_module"], 'event': event, 'msg': msg}

    return json_lpc.invoke_callback(cb_input, input)



def export_device_log(input, callback=invoke_result_callback):
    rpc = global_var.get('rpc')


    # log 文件传输成功标志
    log_trans_flag = False

    # 获取当前时间
    _time = time.strftime("%Y-%m-%d_%H%M%S", time.localtime())

    
    # 拼接设备日志文件路径
    device_log_file_path = "/download/logs/{}.zip".format(_time)

    # 设备日志压缩进度回调
    def __log_zip_callback(event, total_time, remain_time):
        msg = {
            'code': 200,
            'msg': "success",
            'values': {"total_time": total_time, "remain_time": remain_time}
        }

        return callback(input, event, msg)

    

    # log 文件传输进度回调
    def __log_file_trans_callback(event, status, path, start_time, cur_size, total_size):
        nonlocal log_trans_flag
        if event == "onSuccess" or event == "onComplete":
            # 文件传输成功和完成，不要执行回调
            if event == "onSuccess":
                # 传输成功，需要修改标识位
                log_trans_flag = True
            return
        msg = {
            'code': status['code'],
            'msg': status['msg'],
            'values': {'path': path, 'start_time': start_time, 'cur_size': cur_size, 'total_size': total_size}
        }

        return callback(input, _log_file_event_map[event], msg)

    # 设备端日志压缩完成，拉取日志文件
    def __export_total_log():
        # 将设备端日志拉取到该路径
        try:
            __local_device_log = __get_output_path(input, type="device")
        except Exception as e:
            callback(input, "onExportLogFailed", generate_result(CODE_LOG + 20, str(e)))
            return

        logger.debug("pull log archive file {}".format(device_log_file_path))

        pull(__local_device_log, device_log_file_path, True, input, callback=__log_file_trans_callback)

        if not log_trans_flag:
            # 文件拉取失败，直接返回，失败事件在文件传输回调中已经上报

            # 无法确定失败原因，尝试一次重启日志输出
            try:
                rpc.exec_svc(1, "udbd_log_export_finish", bytearray(), need_ack=False,
                             need_rsp=True, timeout=5)
            except Exception as e:
                if e != UrpcSvcNotFoundException:
                    logger.error("exec udbd_log_export_finish failed {}".format(e))
            # 文件拉取失败，不再执行后面的逻辑，失败结果在文件传输回调中已通知应用
            return

        # 文件拉取完成， 重启设备日志输出
        try:
            rpc.exec_svc(1, "udbd_log_export_finish", bytearray(), need_ack=False,
                         need_rsp=True, timeout=5)
        except Exception as e:
            if e != UrpcSvcNotFoundException:
                logger.error("exec udbd_log_export_finish failed {}".format(e))

        # 日志拉取成功之后，删除设备端的日志压缩包文件
        try:
            file_svc.fs_remove(device_log_file_path)
        except Exception as E:
            logger.error("remove device log failed: {}".format(e))
       

        # 将最终的 log 文件路径回调到应用层
        callback(input, "onExportLogSuccess", generate_result(200, 'success', {"path": __local_device_log}))

    file_svc = FileSvc(rpc, rpc.block_size - 58)

    # 检查日志文件是否存在
    log_file_exist = False
    dir_name = bytearray("/download/logs" + '\0', encoding="utf8")

    # dir_name 为目录名
    try:
        result = rpc.exec_svc(1, "lsdir_svc", dir_name, need_ack=False, need_rsp=True, timeout=5)
    except Exception as e:
        callback(input, "onExportLogFailed", generate_result(CODE_LOG + 20, str(e)))
        return

    json_result = json.loads(result.decode('utf-8'))

    if json_result["count"] is not 0:
        for item in json_result["array"]:
            for _name, _type in item.items():
                if _type == "FIL" and _name.startswith("log_20"):
                    device_log_file_path = "/download/logs/" + _name
                    log_file_exist = True
                    break
            if log_file_exist:
                break

    if log_file_exist is True:
        # log 文件存在，直接拉取
        logger.debug("log zip file exist, pull file {}".format(_name))
        __export_total_log()
    else:
        # 文件不存在， 通知设备打包日志

        logger.debug("log zip file not exist, exec udbd_log_export_start")

        args = {}

        args["format"] = input["need_clean"]

        try:
            values = rpc.exec_svc(1, "udbd_log_export_start", bytearray(json.dumps(args), encoding="utf8"), need_ack=False,
                                  need_rsp=True, timeout=5)
        except Exception as e:
            callback(input, "onExportLogFailed", generate_result(CODE_LOG + 20, str(e)))
            return

        values = json.loads(str(values, encoding='utf-8'))

        if values["result"] != 0:
            callback(input, "onExportLogFailed", LOG_ARCHIVE_CODE_TABLE[values['result']])
            return

        logger.debug("archive log file need {}".format(values))

        device_log_file_path = values["output"]

        # 取预估时间的 1.5倍 时间，进行等待设备压缩完成，先 +0.5 ，防止 values['time'] 为 0
        total_time = (values['time'] + 0.5) * 1.5
        remain_time = total_time

        # 设备在压缩日志文件时， 无法获取到进度，模拟一个进度事件

        # 将预估时间的 1.5 倍， 分割成数份， 每份 0.5 s， 即每 0.5s 调用一次进度回调
        _interval = 0.5
        waiting_time = 0
        while (remain_time > 0):
            __log_zip_callback("onArchiveLogProcess", total_time, remain_time)
            if remain_time < (total_time / 5 + _interval) or waiting_time % 3 == 0:
                # 剩余时间小于总时间的 1/5 + _interval ( +_interval 防止 total_time 太小，无法进入判断) ，开始判断设备端文件是否存在
                if file_svc.fs_access(device_log_file_path):
                    # 文件存在，结束循环
                    log_file_exist = True
                    break
            time.sleep(_interval)
            remain_time -= _interval
            waiting_time += _interval


        if log_file_exist:
            __log_zip_callback("onArchiveLogSuccess", total_time, 0)
            __export_total_log()
        else:
            __log_zip_callback("onArchiveLogFailed", total_time, 0)

    return json_lpc.gen_success_output_json()


def export_log(input):

    # 压缩打包 SDK 的日志
    def __export_sdk_log(output_path):

        input_path = Path(os.environ["WEARSERVICE_LOG_PATH"]).parent

        ## strict_timestamps=False 允许压缩时间戳在 1980 年以的文件
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED, strict_timestamps=False) as zipf:
            # 遍历目录中的文件和子目录
            for root, _, files in os.walk(input_path):
                for file in files:
                    # 获取文件的绝对路径
                    file_path = os.path.join(root, file)
                    # 将文件添加到压缩文件中，保留原始的相对路径
                    zipf.write(file_path, os.path.relpath(file_path, input_path))

    _log_output_path = ""

    def __export_log_callback(input, event, msg):
        if event == "onExportLogSuccess":
            # 压缩 sdk 日志
            __export_sdk_log(_log_output_path)

            __local_device_log = msg['values']['path']

            # 将设备端日志写入到压缩包中
            with zipfile.ZipFile(_log_output_path, 'a', zipfile.ZIP_DEFLATED) as zipf:
                zipf.write(__local_device_log, "./device_log.zip")

            logger.debug("-----sdk log zip success-------")
            # 删除无用文件
            os.remove(__local_device_log)

            msg['values']['path'] = _log_output_path

            return invoke_result_callback(input, event, msg)

        else:
            return invoke_result_callback(input, event, msg)

    try:
        _log_output_path = __get_output_path(input, type="wearservice")
    except Exception as e:
        __export_log_callback(input, "onExportLogFailed", generate_result(CODE_LOG + 20, str(e)))
        return
    

    export_device_log(input, callback=__export_log_callback)
    pass
