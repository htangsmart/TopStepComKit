# -*- coding: utf-8 -*-
import threading
import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.quit'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

# 全局 ota_quit 以及使用锁
__ota_quit_value__ = False
__ota_quit_allow__ = False
__ota_quit_lock__ = None


def ota_quit_init(allow_quit):
    if globals()['__ota_quit_lock__'] is None:
        globals()['__ota_quit_lock__'] = threading.Lock()
    # 全局变量加锁
    globals()['__ota_quit_lock__'].acquire()
    # 设置全局退出标识
    globals()['__ota_quit_allow__'] = allow_quit
    globals()['__ota_quit_value__'] = False
    # 全局变量解锁
    globals()['__ota_quit_lock__'].release()


def ota_quit_start():
    if globals()['__ota_quit_lock__'] is None:
        globals()['__ota_quit_lock__'] = threading.Lock()
    # 全局变量加锁
    globals()['__ota_quit_lock__'].acquire()
    # 设置全局退出标识
    if globals()['__ota_quit_allow__'] is True:
        globals()['__ota_quit_value__'] = True
        result = True
    else:
        globals()['__ota_quit_allow__'] = False
        result = False
    # 全局变量解锁
    globals()['__ota_quit_lock__'].release()
    # 返回启动结果
    return result


def ota_quit_check():
    # 获取全局退出标识
    return globals()['__ota_quit_value__']


def ota_quit_allow():
    # 获取全局是否允许退出标识
    return globals()['__ota_quit_allow__']
