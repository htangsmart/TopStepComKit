# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-12-08     xdx       the first version
#

import time
import json
import random
import string

from urpc.src.urpc_utils import *
import global_var
from urpc.src.ffi import *
from wearable import json_lpc
from wearable.json_lpc import gen_success_output_json
from urpc.server.service_status_manage import ServiceStatusManage

LOG_LVL = logging.INFO
LOG_TAG = 'wearable.speed'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def speed_unit(speed):
    unit_B = 'B/s'
    unit_KB = 'KB/s'
    # 如果速度大于1K，则显示KB/s，否则显示B/s
    if speed > 1000:
        speed_str = str(int(speed / 1000)) + unit_KB
    else:
        speed_str = str(int(speed)) + unit_B
    return speed_str


def ping_unit(speed):
    return str(int(speed)) + "ms"


def speed_min_get(speed_min, speed_cur):
    if speed_min == 0:
        speed_min = speed_cur
    else:
        if speed_min > speed_cur:
            speed_min = speed_cur
    return speed_min


def speed_max_get(speed_max, speed_cur):
    if speed_max == 0:
        speed_max = speed_cur
    else:
        if speed_max < speed_cur:
            speed_max = speed_cur
    return speed_max


def watch_download(index, send_str, block_size):
    rpc = global_var.get('rpc')
    # 设置传输序号、传输数据、传输长度
    send_idx = Arg(U32, index)
    send_buf = Arg(U8 | ARRAY, bytearray(json.dumps(send_str[:block_size]) + '\0', encoding="utf8"))
    send_len = Arg(U32, send_buf.value_len)
    return rpc.exec_ffi_func(1, "_null", [send_idx, send_buf, send_len], need_ack=False, need_rsp=True, timeout=3)


def watch_upload(index, send_str, block_size):
    rpc = global_var.get('rpc')
    # 设置传输序号、传输数据、传输长度
    send_idx = Arg(U32, index)
    send_buf = Arg(U8 | ARRAY | EDITABLE, bytearray(json.dumps(send_str[:block_size]) + '\0', encoding="utf8"))
    send_len = Arg(U32, send_buf.value_len)
    return rpc.exec_ffi_func(1, "_null", [send_idx, send_buf, send_len], need_ack=False, need_rsp=True, timeout=3)


def watch_ping(index):
    rpc = global_var.get('rpc')
    # 设置传输序号、传输数据、传输长度
    send_idx = Arg(U32, index)
    send_buf = Arg(U8 | ARRAY, bytearray('\0', encoding="utf8"))
    send_len = Arg(U32, send_buf.value_len)
    return rpc.exec_ffi_func(1, "_null", [send_idx, send_buf, send_len], need_ack=False, need_rsp=True, timeout=3)


def service_speed(input):
    class SpeedInfo:
        def __init__(self, ):
            self.cur = 0
            self.min = 0
            self.max = 0
            self.avr = 0
            self.total_data_len = 0
            self.total_trans_time = 0

    def calc_speed(speed, data_len, trans_time):
        speed.total_trans_time += trans_time
        speed.total_data_len += data_len
        # 计算当前速度
        speed.cur = int(data_len / trans_time)
        # 计算最小速度
        speed.min = speed_min_get(speed.min, speed.cur)
        # 计算最大速度
        speed.max = speed_max_get(speed.max, speed.cur)
        # 计算平均速度
        speed.avr = int(speed.total_data_len / speed.total_trans_time)
        # 调试输出
        logger.info("send_curr  = %d byte, time_curr  = %f ms, speed = %d Bytes/s", data_len, trans_time *1000, speed.cur)
        logger.info("send_total = %d byte, time_total = %f ms, speed = %d Bytes/s", speed.total_data_len, speed.total_trans_time *1000, speed.cur)

    rpc = global_var.get('rpc')
    block_size = rpc.block_size - 48
    output = gen_success_output_json()
    # 组装传输数据，初始化为5000字节长度的字符串，使用时依据block_size进行截取使用
    send_str = ""
    results = []
    index = 0
    time_total = 0
    send_total = 0
    failed_count = 0
    success_count = 0
    down = SpeedInfo()
    up = SpeedInfo()
    ping = SpeedInfo()
    # 0: download 1: upload 2: ping
    test_mode = 0

    test_time = int(input['time'])
    if test_time <= 0:
        test_time = 5
    # 计算当前时间与结束时间
    current_time = time.time()
    finish_time = current_time + test_time

    # 如果未结束，则需要一直发送
    while current_time < finish_time:
        send_str = ""
        for i in range(100):
            result = random.sample(string.ascii_letters, 50)
            results.append("".join(result))
        for i in range(100):
            send_str = send_str + results[i]

        time_start = time.time()
        # 一次测试下行，一次测试上行，一次测试时延
        if test_mode == 0:
            result = watch_download(index, send_str, block_size)
        elif test_mode == 1:
            result = watch_upload(index, send_str, block_size)
        else:
            result = watch_ping(index)
        time_finish = time.time()

        logger.info("result.value = %d, index = %d", result.value, index)
        # 判断是否传输成功
        if result.value == index:
            # 如果传输成功则记录传输总长度与传输总时间
            time_curr = time_finish - time_start
            # 一次测试下行，一次测试上行，一次测试时延
            if test_mode == 0:
                calc_speed(down, len(send_str), time_curr)
            elif test_mode == 1:
                calc_speed(up, len(send_str), time_curr)
            else:
                # 时延 等于 传输时间，所以第三个参数传了 1
                calc_speed(ping, time_curr*1000, 1)
            # 成功次数加1
            success_count = success_count + 1
        else:
            # 失败次数加1
            failed_count = failed_count + 1

        # 计算剩余时间
        last_time = int(finish_time - current_time)
        # 切换传输测试模式
        if float(last_time) >= float(test_time * 0.6):
            # 下行测试
            test_mode = 0
        elif float(last_time) >= float(test_time * 0.2):
            # 上行测试
            test_mode = 1
        elif float(last_time) >= float(test_time * 0.0):
            # 时延测试
            test_mode = 2
        # 上传当前状态
        output["values"] = '手表下行速度：最小: ' + speed_unit(down.min) + ' 最大: ' + speed_unit(down.max) + ' 平均: ' + speed_unit(down.avr) + '\n' \
                           '手表上行速度：最小: ' + speed_unit(up.min) + ' 最大: ' + speed_unit(up.max) + ' 平均: ' + speed_unit(up.avr) + '\n' \
                           '手表ping时延：最小: ' + ping_unit(ping.min) + ' 最大: ' + ping_unit(ping.max) + ' 平均: ' + ping_unit(ping.avr) + '\n' \
                           ' \n剩余时间:' + str(last_time) + \
                           ' \n成功次数:' + str(success_count) + \
                           ' \n失败次数:' + str(failed_count)
        result = {'module': input["_module"], 'event': "Success", 'msg': output}
        logger.info(result)
        json_lpc.invoke_callback(result, input)
        # 查询当前时间
        current_time = time.time()

    result = {'module': input["_module"], 'event': "Finish", 'msg': output}
    # 上传测试状态
    json_lpc.invoke_callback(result, input)
    return output


def service_echo(input):
    rpc = global_var.get('rpc')
    send_msg = input['msg']
    send_buf = bytearray(send_msg, encoding="utf8")
    recv = rpc.exec_svc(1, "_echo", send_buf, need_ack=False,
                        need_rsp=True, timeout=3)
    output = gen_success_output_json()
    output['values'] = recv.decode('utf-8')
    return output


def watch_lost(index, send_str, block_size, reset):
    rpc = global_var.get('rpc')
    # 设置传输序号、传输数据、传输长度
    send_idx = Arg(U32, index)
    send_buf = Arg(U8 | ARRAY, bytearray(json.dumps(send_str[:block_size]) + '\0', encoding="utf8"))
    send_len = Arg(U32, send_buf.value_len)
    send_ret = Arg(U32, reset)
    try:
        output = rpc.exec_ffi_func(1, "_lost", [send_idx, send_ret, send_buf, send_len], need_ack=False, need_rsp=True, timeout=1, retry=0)
    except UrpcDisconnectException as e:
        return "disconnect"
    except UrpcTimeoutException as e:
        return "timeout"
    return output



def service_lost_start(input):
    # 定义发送的数据长度
    rpc = global_var.get('rpc')
    block_size = rpc.block_size - 48
    output = gen_success_output_json()
    results = []

    test_time = int(input['time'])
    # 计算当前时间与结束时间
    if test_time <= 0:
        current_time = time.time()
        finish_time = current_time + 5
    elif test_time < 5:
        test_time = 5
        current_time = time.time()
        finish_time = current_time + test_time
    else:
        current_time = time.time()
        finish_time = current_time + test_time

    # 设置停止测试状态
    global_var.set('lost_stop', False)
    # 重置索引值
    index = 0
    send_str = ""
    send_timeout_count = 0
    device_return_lost = 0

    watch_lost(index, send_str, block_size, reset=1)
    # 如果未结束，则需要一直发送
    while current_time < finish_time:
        # 组装传输数据，初始化为5000字节长度的字符串，使用时依据block_size进行截取使用
        for i in range(100):
            result = random.sample(string.ascii_letters, 50)
            results.append("".join(result))
        for i in range(100):
            send_str = send_str + results[i]
        # 发送数据
        result = watch_lost(index, send_str, block_size, reset=0)
        # 返回超时，失败次数加1
        if result == "timeout" or result is None:
            send_timeout_count = send_timeout_count + 1
        # 返回断连，等待3秒后继续
        elif result == "disconnect":
            time.sleep(3)
            continue
        # 其它情况，查询剩余时间
        if test_time > 0:
            current_time = time.time()
            last_time = int(finish_time - current_time)
            # 返回结果
            output["values"] =  ' 发送索引编号 : ' + str(int(index)) + '\n' + \
                                ' 手表丢包数量 : ' + str(int(device_return_lost)) + '\n' + \
                                ' 发送超时数量 : ' + str(int(send_timeout_count)) + '\n' + \
                                ' 剩余测试时间 : ' + str(int(last_time)) + 's'
        else:
            last_time = int(time.time() - current_time)
            # 返回结果
            output["values"] =  ' 发送索引编号 : ' + str(int(index)) + '\n' + \
                                ' 手表丢包数量 : ' + str(int(device_return_lost)) + '\n' + \
                                ' 发送超时数量 : ' + str(int(send_timeout_count)) + '\n' + \
                                ' 持续测试时间 : ' + str(int(last_time)) + 's'
        # 手机显示
        result = {'module': input["_module"], 'event': "Success", 'msg': output}
        logger.info(result)
        json_lpc.invoke_callback(result, input)
        # 查询是否需要停止测试
        if global_var.get('lost_stop') is True:
            break
        # 索引值自增
        if (int(index) + 1) < 0:
            index = 0
        else:
            index = index + 1

    # 返回结果
    result = {'module': input["_module"], 'event': "Finish", 'msg': output}
    # 上传测试状态
    json_lpc.invoke_callback(result, input)
    return output


def service_lost_stop(input):
    # 设置停止测试状态
    global_var.set('lost_stop', True)
