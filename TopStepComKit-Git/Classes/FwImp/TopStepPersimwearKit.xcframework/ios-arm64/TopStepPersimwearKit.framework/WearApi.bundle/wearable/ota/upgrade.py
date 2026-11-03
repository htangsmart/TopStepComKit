# -*- coding: utf-8 -*-

import importlib.util as Importlib
import os, re

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

class Upgrade(object):
    """
    通用升级对象构造类，基于不同的类型构造升级对象
    :param __parameter__: 保存构造函数的入参
    :param __upgrade_info__: 升级信息，其中包含了相关的升级方法
    """

    def __init__(self, parameter, config):
        super().__init__()

        logger.info("try find uses:%s." % (parameter["uses"]))
        path = os.path.join(os.path.split(__file__)[0], 'upgrade')
        if not os.path.isdir(path):
            # 在当前脚本目录下，必须存在 upgrade 文件夹
            raise Exception('\'upgrade\' dir not find. path:%s' % path)
        # 获取升级模块
        dir_list = os.listdir(path)
        for fn in dir_list:
            load_file_path = os.path.join(path, fn)
            # 检查文件是否存在，并且命名方式是 xxx.py 的形式
            if os.path.isfile(load_file_path) and re.match('^[a-zA-Z_][a-zA-Z0-9_]*.py$', fn):
                # 导入模块
                function_name = 'upgrade'
                module_spec = Importlib.spec_from_file_location(function_name, load_file_path)
                module = Importlib.module_from_spec(module_spec)
                module_spec.loader.exec_module(module)
                # 使用反射机制，获取升级模块信息
                upgrade_info = module.__dict__[function_name]()
                # 匹配升级方法
                if parameter["uses"] in upgrade_info["name"]:
                    logger.info("find uses:%s in %s" % (parameter["uses"], str(module)))
                    self.__parameter__ = parameter
                    self.__config__ = config
                    self.__upgrade_info__ = upgrade_info
                    return
        # 未查找到相关的升级方法，抛出异常
        raise Exception('upgrade step %s not find' % parameter["uses"])

    def init(self):
        # 调用 new 方法，创建升级对象
        self.__upgrade_object__ = self.__upgrade_info__["new"](self.__parameter__, self.__config__)

    def progress(self):
        # 调用对象的获取进度方法
        return self.__upgrade_object__.progress()

    def due_time(self):
        # 调用对象的截至时间方法
        return self.__upgrade_object__.due_time()

    def run(self):
        # 调用对象的运行方法，升级程序
        return self.__upgrade_object__.run()

    def quit(self):
        self.__upgrade_object__.quit()
