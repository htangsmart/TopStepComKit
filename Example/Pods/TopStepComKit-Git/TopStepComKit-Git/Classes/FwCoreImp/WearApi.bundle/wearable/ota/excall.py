# -*- coding: utf-8 -*-

import importlib.util as Importlib
import os
import re

cache_table = {}


def excall(fpath, fname, *args):
    """
    p: 文件路径
    m: 函数名
    """
    fpath = str(fpath)
    fname = str(fname)
    # 检查路径是否合法
    if not os.path.isfile(fpath):
        raise Exception("The file path<%s> does not exist" % str(fpath))
    # 检查不定参个数
    if len(args) > 12:
        raise RuntimeError('Too many function arguments')
    ff = fpath + '.' + fname
    if ff in cache_table:
        module = cache_table[ff][0]
    else:
        # 查找模块及函数
        module_spec = Importlib.spec_from_file_location(fname, fpath)
        module = Importlib.module_from_spec(module_spec)
        module_spec.loader.exec_module(module)
        cache_table[ff] = (module, module_spec)
    # 使用反射机制，调用函数
    args_len = len(args)
    if args_len == 0:
        return module.__dict__[fname]()
    elif args_len == 1:
        return module.__dict__[fname](args[0])
    elif args_len == 2:
        return module.__dict__[fname](args[0], args[1])
    elif args_len == 3:
        return module.__dict__[fname](args[0], args[1], args[2])
    elif args_len == 4:
        return module.__dict__[fname](args[0], args[1], args[2], args[3])
    elif args_len == 5:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4])
    elif args_len == 6:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5])
    elif args_len == 7:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5], args[6])
    elif args_len == 8:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
    elif args_len == 9:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    elif args_len == 10:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
                                      args[9])
    elif args_len == 11:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
                                      args[9],
                                      args[10])
    elif args_len == 12:
        return module.__dict__[fname](args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
                                      args[9],
                                      args[10], args[11])
    else:
        return None
