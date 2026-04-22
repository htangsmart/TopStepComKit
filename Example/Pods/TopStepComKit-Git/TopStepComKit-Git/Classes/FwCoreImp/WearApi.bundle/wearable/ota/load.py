# -*- coding: utf-8 -*-

import importlib.util as Importlib
import os
import re
import zipfile
import shutil

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.load'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def unpackage_zip_file(package, unpackage_path):
    # 检查资源文件路径是否存在
    package_path = os.path.abspath(package)
    if not os.path.isfile(package_path):
        raise Exception('OTA upgrade file does not exist. %s' % package_path)
    logger.info('ota package path: %s' % package_path)

    # 清理解压目录
    outpath = os.path.abspath(unpackage_path)
    if os.path.isfile(outpath):
        # 检查路径是一个文件，直接删除
        logger.info('clean file. %s' % outpath)
        os.remove(outpath)
    elif os.path.isdir(outpath):
        logger.info('clean dir. %s' % outpath)
        shutil.rmtree(outpath)
    # 创建解压目录
    if os.path.exists(outpath) and (not os.listdir(outpath)):
        raise Exception('File directory is not empty. %s' % str(outpath))
    else:
        logger.info('make outpath dir. %s' % str(outpath))
        os.makedirs(outpath)

    # 尝试加载zip升级包
    try:
        zf = zipfile.ZipFile(package_path, mode='r', compression=zipfile.ZIP_DEFLATED)
        # 获取压缩包中所有文件列表
        zip_file_list = zf.namelist()
    except Exception:
        raise Exception(
            'OTA upgrade package decompression failed. It is not a valid zip package. %s' % package_path)

    # 解压文件,写入到输出目录
    for fn in zip_file_list:
        _tmp_path = os.path.abspath(os.path.join(outpath, fn)).replace('\\', '/')
        logger.info('unzip file: %s' % _tmp_path)
        try:
            # 将文件解压到指定目录下
            zf.extract(fn, outpath)
        except Exception as e:
            # 操作异常，关闭 zip 文件
            zf.close()
            raise e
    # zip 文件读取完成，关闭 zip 文件
    zf.close()
    logger.info('OTA upgrade package decompression success')


def get_load_modules():
    # 查找资源包加载模块，获取当前文件路径，并检查该路径下是否有 load 文件夹
    load_path = os.path.join(os.path.split(__file__)[0], 'load')
    if not os.path.isdir(load_path):
        # 在当前脚本目录下，必须存在 load 文件夹。且 lode 文件夹中存放加载资源包的方法
        raise Exception('\'load\' dir not find')
    # 从文件夹中加载资源包解析模块
    modules = []
    dir_list = os.listdir(load_path)
    for fn in dir_list:
        load_file_path = os.path.join(load_path, fn)
        # 检查文件是否存在，并且命名方式是 XXXLoad.py 的形式
        if os.path.isfile(load_file_path) and re.match('^[a-zA-Z_][a-zA-Z0-9_]*Load.py$', fn):
            # 从文件中加载 Load 方法，后续会调用 Load 方法，加载资源文件
            module_spec = Importlib.spec_from_file_location('Load', load_file_path)
            module = Importlib.module_from_spec(module_spec)
            module_spec.loader.exec_module(module)
            logger.info('find module. %s' % str(module))
            # 将加载的资源包解析模块收集起来
            modules.append(module)
    # 返回模块
    return modules


class Load(object):
    """
    :param __load__: 资源包加载对象
    """

    def __init__(self, package, unpackage_path):
        """
        Load 资源包解析构造对象
        :param package: 资源包路径
        :param unpackage_path: 资源包解压路径
        """
        super().__init__()

        # 解压资源包
        unpackage_zip_file(package, unpackage_path)
        # 解析资源包
        for m in get_load_modules():
            try:
                logger.info('Try loading with %s' % str(m))
                # 反射机制，调用 module 对象中的 Load 方法
                load_object = m.__dict__['Load'](unpackage_path)
            except Exception as e:
                logger.warning('Failed to load using %s' % str(m))
                logger.warning(str(e))
                continue
            # 检查对象是否构造成功。若没有构造成功，则使用下一个模块解析资源包
            if isinstance(load_object, object):
                self.__load__ = load_object
                logger.info('Successfully loaded with %s.' % (str(m)))
                logger.info('load package %s success.' % str(package))
                return
        # 资源包无法解析，上报异常
        raise Exception('load package failed')

    def steps(self):
        """
        获取升级步骤
        """
        return self.__load__.steps()

    def config(self):
        """
        获取升级配置信息
        """
        return self.__load__.config()

    def version(self):
        """
        获取升级包版本
        """
        return self.__load__.version()

    def need_reboot(self):
        """
        是否要求设备重启
        """
        return self.__load__.need_reboot()

    def allow_quit(self):
        """
        是否允许退出
        """
        return self.__load__.allow_quit()
