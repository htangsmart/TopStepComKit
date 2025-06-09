# -*- coding: utf-8 -*-
# from https://zhuanlan.zhihu.com/p/349108535

_global_dict = {}

def init():  # 初始化
    global _global_dict
    _global_dict = {}


def set(key, value):
    # 定义一个全局变量
    _global_dict[key] = value


def get(key):
    # 获得一个全局变量，不存在则提示读取对应变量失败
    if has(key):
        return _global_dict[key]
    else:
        print('get ' + key + ' failed')


def has(key):
    try:
        value = _global_dict[key]
        return True
    except:
        return False


def remove(key):
    return _global_dict.pop(key)
