#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2021, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-10-24     armink       the first version
#


import os
from pathlib import Path
import sys
# 将当前目录添加到怕 python的环境变量中，在后面引入模块是才能找到目录中的模块
parent_path = os.path.dirname(__file__)

sys.path.append(parent_path)
import json
import logging
from logging.handlers import RotatingFileHandler
from mcf.mcf_utils import set_native_crc_func


import global_var
from mcf.aslog.aslog import AsyncStream


print("Starting 'bootstrap.py'")

global_var.init()


if 'WEARSERVICE_LOG_PATH' in os.environ:
    path = os.environ["WEARSERVICE_LOG_PATH"]
else:
    # 没有设置日志存储的路径或者设置失败时，获取当前路径
    print("log path env inviable")
    cur_path = os.path.dirname(__file__)
    if cur_path.startswith("/var/containers/"):
        #  ios 设备
        cur_path = Path(cur_path)
        path = cur_path.parent.parent.parent
    else:
        #  android 设备
        path = '/storage/emulated/0/Android/data/com.realthread.wearservice/logs/wearservice/'

try:
    import wearservice_crc
    set_native_crc_func(wearservice_crc.crc16, wearservice_crc.crc32)
except Exception as e:
    print(e)

# 创建日志文件夹
log_path = Path(path)
print("log_path ddddd")
print(log_path)
global_var.set("log_path", path)
if not log_path.exists():
    # 目录不存在则创建
    os.makedirs(path)
# 文件 handler 。循环模式，最多 10 个日志文件，每个日志文件最大 5MB
file_handler = RotatingFileHandler(path + '/wearcore.log', maxBytes=5 * 1024 * 1024, backupCount=10)
formatter = logging.Formatter('%(asctime)s|%(name)-15s: %(levelname)-8s %(message)s')
file_handler.setFormatter(formatter)
file_handler.setLevel(level=logging.DEBUG)
# 控制台 handler
console_handler = logging.StreamHandler()
formatter = logging.Formatter('%(name)s %(levelname)s: %(message)s')
console_handler.setFormatter(formatter)
console_handler.setLevel(level=logging.INFO)
# 构造异步日志输出流
async_stream = AsyncStream()
# 初始化日志库
logging.basicConfig(level=logging.DEBUG, handlers=[file_handler, console_handler],
                    format='%(name)s %(levelname)s: %(message)s')


def router(args):
    """
    Defines the router function that routes by function name.

    :param args: JSON arguments
    :return: JSON response
    """
    values = json.loads(args)

    try:
        function = routes[values.get('function')]

        status = 'ok'
        res = function(values)
    except KeyError:
        status = 'fail'
        res = None

    return json.dumps({
        'status': status,
        'result': res,
    })


def greet(args):
    """Simple function that greets someone."""
    return 'Hello %s' % args['name']


def add(args):
    """Simple function to add two numbers."""
    return args['a'] + args['b']


def mul(args):
    """Simple function to multiply two numbers."""
    return args['a'] * args['b']


routes = {
    'greet': greet,
    'add': add,
    'mul': mul,
}
