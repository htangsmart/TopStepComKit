# -*- coding: utf-8 -*-
import os
import time
import traceback
import global_var
from wearable.ota import load, upgrade, progress, excall
from wearable.ota.context import Context
from wearable.ota.runner import *
from wearable.ota.quit import *
import json
from urpc.src.urpc_utils import *
from urpc.server.service_status_manage import ServiceStatusManage

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.main'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

ota_progress_update_last_time = 0

"""
手机与手表交互格式
{
    "state":           'onProcess':开始传输，'onSuccess':传输成功，'onFailed':传输失败，'onComplete':传输完成, 'onQuit':退出传输
    "progress":        0-100
    "time":            0-3600s  已经传输时间
    "remain_time":     0-3600s  剩余时间
    "file":            当前正常传输文件状态
        {
            "name"：        文件名
            "total"：       文件大小
            "code":         错误码
            "progress":     当前文件传输进度
            "size"          传输大小
            "time"：        传输时间
            "remain_time":  剩余时间
        }
}
"""

ota_process_has_end = False


class _NotifyParam(object):
    """
    :param total_progress: 实时进度对象
    :param last_progress: 上一次进度值
    :param start_time: 启动时间
    :param last_time: 上次失败时间
    :param retry_cnt: 重试次数
    进度通知函数参数类
    """

    def __init__(self, p):
        super().__init__()
        self.total_progress = p
        self.last_progress = 0.0
        self.start_time = round(time.time())
        self.last_time = round(time.time())
        self.retry_cnt = 1


def __service_ota_upgrade_message_report(event, message, code, msg):
    __service_ota_set_sync_progress(message)
    __service_report_progress_mobile(event, message, code, msg)
    

# 将进度发送到手表，不在需要应用层发送进度
def __service_ota_set_sync_progress(param):
    rpc = global_var.get('rpc')
    rpc.exec_svc(1, "svc_ota_set_sync_progress", bytearray(json.dumps(param), encoding="utf8"),
                          need_ack=False, need_rsp=False, timeout=3)
    
def __service_report_progress_mobile(event, message, code, msg):
    global ota_process_has_end
    if ota_process_has_end:
        return
    if event == "onFailed" or event == "onSuccess":
        ota_process_has_end = True
    report_pohone_message = {
        'code': code,
        'msg': msg,
        'values': message
    }
    if event == 'onSuccess' or event == 'onFailed' and 'file' in report_pohone_message['values']:
        del report_pohone_message['values']['file']
    return excall.excall(os.path.join(os.path.split(__file__)[0], 'service/service_port.py'),
                         'service_ota_upgrade_message_report', event, report_pohone_message)


def __ota_percentage_callback(msgs, param):
    """
    显示及上报当前 OTA 进度，内部函数
    :param p: 整体进度对象
    :param last_progress: 上一次进度值
    """

    p = param.total_progress
    if p.is_complete():
        # 升级完成的状态，不在此处上报(完成包括：成功/失败)
        return

    logger.info("ota progress:%f msg:%s" % (p.percentage(), str(msgs)))
    if msgs and 'upgrade' in msgs and 'file_info' in msgs and msgs["upgrade"] in ('directory_upgrade', 'file_upgrade'):
        file_info = {
            "name": msgs["file_info"]["name"],
            "total": msgs["file_info"]["total"],
            "code": str(msgs["file_info"]["code"]['code']) +  msgs["file_info"]["code"]['msg'],
            "progress": int(msgs["file_info"]["progress"] * 100),
            "size": msgs["file_info"]["size"],
            "time": int(msgs["file_info"]["time"] / 1000),
            "remain_time": int(msgs["file_info"]["remain_time"] / 1000)
        }
    else:
        file_info = {
            "name": '',
            "total": 0,
            "code": 'progress',
            "progress": 0,
            "size": 0,
            "time": 0,
            "remain_time": 0
        }
    details = p.details()
    # 由于存在断连等原因，真实进度值可能重置。为了用户体验，当真实进度值重置后，使用上一次的进度作为显示的进度
    tmp = details["percentage"]
    # if details["percentage"] > param.last_progress:
    #     tmp = details["percentage"]
    # 构造进度消息
    if msgs and 'file_info' in msgs:
        code = msgs["file_info"]["code"]['code']
        msg = msgs["file_info"]["code"]['msg']
    else:
        code = 200
        msg = 'progress'
    message = {
            "state": 'onProcess',
            "progress": round(tmp * 100, 4),
            "time": round(time.time()) - param.start_time,
            "remain_time": int(details["remain_time"] / 1000),
            "file": file_info,
            "error": ''
    }
    # 计算两次更新的时间差
    global ota_progress_update_last_time
    curr_time = int(round(time.time() * 1000))
    diff_time = (curr_time - ota_progress_update_last_time)
    # 获取总进度与单个文件进度
    total_progress = message["progress"]
    files_progress = file_info["progress"]
    # 如果两次更新的时间差大于500毫秒，或者总进度达到100%，或者单个文件进度达到100%，才会显示进度。
    if (diff_time > 500) or (total_progress >= 100) or (files_progress >= 100) :
        # 发送给手机端显示
        __service_ota_upgrade_message_report('onProcess', message, code, msg)
        ota_progress_update_last_time = curr_time
    else:
        # 只通过日志输出
        logger.info("ota progress upgrade too short, diff time: %d ms, total progress: %d, file progress: %d " % (diff_time, total_progress, files_progress))


def __ota_exit_process(quit_step_list):
    # 执行退出升级步骤
    try:
        for step in quit_step_list:
            step.quit_run()
    except UrpcDisconnectException as e:
        raise UrpcDisconnectException()
    except Exception as ex:
        logger.error('exception occurred. error:%s' % (ex.__str__()))
        logger.error(traceback.format_exc())


def ota_main(ota_path, retry=5):
    """
    OTA 升级主程序入口
    :param ota_path: OTA 资源包路径
    :param retry: OTA 重试次数
    """
    global ota_process_has_end

    ota_process_has_end = False

    # 检查资源包路径是否合法
    if not os.path.isfile(ota_path):
        ota_result = {
            "state": "onFailed",
            "progress": 0,
            "time": 0,
            "remain_time": 0,
            "file": {},
            "error": 'Is not a valid file path {}'.format(str(ota_path))
        }
        __service_ota_upgrade_message_report("onFailed", ota_result, 500, 'failed')
        raise Exception('Is not a valid file path:%s' % str(ota_path))
    # 获取 ota 包所在路径
    out_path = os.path.join(os.path.split(ota_path)[0], 'unpackage')
    # 装载升级包
    resource = load.Load(ota_path, out_path)
    # 退出升级相关初始化
    ota_quit_init(resource.allow_quit())
    # 清空退出升级步骤列表
    quit_step_list = []
    # 创建升级对象
    step_list = runner_list_create(resource)
    # 初始化升级对象
    for s in step_list:
        s.init()
    total_progress = progress.ProgressVC("ota main")
    # 获取升级进度
    for s in step_list:
        total_progress.append(s.progress(), s.due_time())
    param = _NotifyParam(total_progress)
    # 设置进度通知函数
    total_progress.set_notify(__ota_percentage_callback, param)
    # 清空上次同步进度的时间
    global ota_progress_update_last_time
    ota_progress_update_last_time = 0

    if not ServiceStatusManage().get_wear_service_status():
        raise UrpcDisconnectException()

    # 初始化升级结果
    ota_result = {
        "state": "onProcess",
        "progress": int(total_progress.percentage() * 100),
        "time": round(time.time()) - param.start_time,
        "remain_time": 0,
        "file": {},
        "error": ''
    }
    # 开始升级
    while not total_progress.is_success():
        # 重置进度
        total_progress.reset()
        """
        一旦进入升级模式，设备测无法还原，要尽最大努力，将设备升级成功！！
        1. 中途失败不退出，反复进行重试

        退出条件
        1. 10 分钟内持续失败，且进度值没有增加
        2. 升级包允许退出升级，且被主动设置退出
        """
        # 判断是否长时间没有动作
        if int(round(time.time())) - param.last_time > (10 * 60):
            logger.error('Upgrade failed, exceeding the maximum waiting time')
            break
        # 判断是否处于需要退出升级
        if ota_quit_check() is True:
            # 尝试执行主动退出升级步骤
            __ota_exit_process(quit_step_list)
            break
        # 执行升级步骤
        for runner in step_list:
            try:
                # 记录正现在运行的runner
                quit_step_list.insert(0, runner)
                # 执行runner
                runner.run()
                # 判断是否已经退出升级
                if ota_quit_check() is True:
                    break
            except UrpcDisconnectException as e:
                ota_result["state"] = 'onFailed'
                ota_result["error"] = "WearService link disconnect"
                __service_report_progress_mobile("onFailed", ota_result, 502, 'failed')
                break
            except Exception as ex:
                logger.error('exception occurred. error:%s' % (ex.__str__()))
                logger.error(traceback.format_exc())
                ota_result["state"] = 'onFailed'
                ota_result["error"] = total_progress.error()
                __service_report_progress_mobile("onFailed", ota_result, 500, 'failed')
                break
            
            # 检查是否执行失败
            if total_progress.is_failed():
                ota_result["error"] = total_progress.error()
                __service_ota_upgrade_message_report("onProcess", ota_result, 200, 'process')
                logger.error('runner error. retry:%d. p:%f' % (param.retry_cnt, total_progress.percentage()))
                time.sleep(1)
                break

        # 如果进度未完成，输出调试信息，便于观察各个进度的状态
        if total_progress.is_complete() is False:
            total_progress.debug()

        # 检查进度是否有增长
        if total_progress.percentage() > param.last_progress:
            # 进度值有增加，可以继续尝试
            param.last_time = int(round(time.time()))
        # 保存当次进度
        param.last_progress = total_progress.percentage()
        # 判断是否需要退出升级
        if ota_quit_check() is True:
            # 尝试执行主动退出升级步骤
            __ota_exit_process(quit_step_list)
            break
        # 重试次数增加
        param.retry_cnt = param.retry_cnt + 1
        # 超过重试次数，退出升级
        if param.retry_cnt > retry:
            break

    # 清理升级上下文文件
    try:
        Context().delete()
    except UrpcDisconnectException as ex:
        logger.warning('clean context file failed. waring:%s' % (ex.__str__()))
        logger.warning(traceback.format_exc())
        ota_result["state"] = 'onFailed'
        ota_result["error"] = "WearService link disconnect"
        __service_report_progress_mobile("onFailed", ota_result, 502, 'failed')

    except Exception as ex:
        logger.warning('clean context file failed. waring:%s' % (ex.__str__()))
        logger.warning(traceback.format_exc())
        ota_result["state"] = 'onFailed'
        ota_result["error"] = total_progress.error()
        __service_ota_upgrade_message_report("onFailed", ota_result, 500, 'failed')

    # 如果为退出升级状态
    if ota_quit_check() is True:
        ota_result["state"] = 'onQuit'
        ota_result["progress"] = 100
        __service_ota_upgrade_message_report("onQuit", ota_result, 200, 'success')
        return
    # 上报最终结果
    if total_progress.is_success():
        ota_result["state"] = 'onSuccess'
        ota_result["progress"] = 100
        __service_ota_upgrade_message_report("onSuccess", ota_result, 200, 'success')
    else:
        ota_result["state"] = 'onFailed'
        ota_result["error"] = total_progress.error()
        __service_ota_upgrade_message_report("onFailed", ota_result, 500, 'failed')


def ota_quit():
    # 退出升级
    result = ota_quit_start()
    # 启动退出升级成功
    if result is True:
        # 通知各个runner退出升级
        step_list = runner_list_obtain()
        for step in step_list:
            step.quit()
    # 返回退出升级处理结果
    return result
