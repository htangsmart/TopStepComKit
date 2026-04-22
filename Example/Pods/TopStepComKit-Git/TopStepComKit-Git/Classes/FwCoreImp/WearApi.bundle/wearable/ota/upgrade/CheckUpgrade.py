# -*- coding: utf-8 -*-

import os
import json

import global_var
from urpc.services.file import FileSvc
from wearable import path
from mcf.mcf_utils import calculate_crc32

from wearable.ota.progress import Progress, ProgressVC

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.CheckUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class CheckUpgrade(object):
    """
    校验升级类，校验本地文件与远端文件是否相对，并生成 json 文件，发送至远端
    :param __progress__: 进度容器，保存一组文件的进度信息
    :param __upgrade_info__: 类初始化入参，保存一份
    """

    def __init__(self, upgrade_info, config):
        """
        :param: upgrade_info 信息如下:
            {
                "remote": key,          # 仅检查文件夹
                "path": '/xx/xx'        # 本地目录路径
            }
        """
        super().__init__()

        local = str(upgrade_info["path"])

        # 查询本地文件数量
        def __list_local_dir(p):
            abs_local_path = os.path.abspath(os.path.join(local, p))
            tmp_list = os.listdir(abs_local_path)
            file_list = []
            for l in tmp_list:
                tmp_path = os.path.join(p, l).replace('\\', '/')
                tmp_abs_path = os.path.join(abs_local_path, l)
                if os.path.isdir(tmp_abs_path):
                    # 递归查找本地路径信息
                    file_list = file_list + [tmp_path]
                    file_list = file_list + __list_local_dir(tmp_path)
                elif os.path.isfile(tmp_abs_path):
                    file_list = file_list + [tmp_path]
            return file_list

        local_list = __list_local_dir('.')
        # 排序本地文件列表
        if len(local_list) > 0:
            local_list = sorted(local_list, reverse=False)
        # 初始化对象成员
        rpc = global_var.get('rpc')
        self.__svc__ = FileSvc(rpc, rpc.block_size - 58)
        self.__rpc__ = rpc
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__progress__ = Progress(upgrade_info["path"], len(local_list))
        self.__local_list__ = local_list
        self.__remote__ = os.path.join('/', str(upgrade_info["remote"])).replace('\\', '/')
        self.__remote_object__ = path.Path(self.__remote__)
        self.__local__ = local
        if 'time' in upgrade_info:
            self.__due_time__ = int(upgrade_info["time"])
        else:
            # 每个文件检查时间约 3 秒
            self.__due_time__ = len(local_list) * 3
        # 是否处于退出状态
        self.__quit__ = False

    def run(self):
        """
        执行检查方法
        :return:
        """
        # 复位进度
        self.__progress__.reset()
        # 开始进度
        self.__progress__.set_start()
        # 初始化检查路径
        file_check_result = []
        remote_path = self.__remote_object__
        file_list = self.__local_list__
        local = self.__local__
        # 遍历本地文件列表,开始检查
        for i in file_list:
            abs_local_path = os.path.abspath(os.path.join(local, i))
            abs_remote_path = remote_path.abspath(i)
            # 本地是一个文件夹
            if os.path.isdir(abs_local_path):
                logger.info('check dir: ' + i)
                if not remote_path.isdir(abs_remote_path):
                    # 远端不是一个文件夹
                    err_msg = 'check upgrade file failed, local(%s) is dir. remote(%s) not dir' % (abs_local_path, abs_remote_path)
                    self.__progress__.set_fail(err_msg)
                    logger.error(err_msg)
                    return False
            elif os.path.isfile(abs_local_path):
                # 本地路径是一个文件，校验文件 CRC
                logger.info('check file: ' + i)
                # 获取远端文件 CRC
                try:
                    remote_path_crc = ('%08x' % remote_path.crc32(abs_remote_path))
                except Exception as ex:
                    err_msg = 'check upgrade file failed, remote(%s) is invalid.' % (abs_remote_path)
                    self.__progress__.set_fail(err_msg)
                    logger.error(err_msg)
                    return False
                # 计算本地文件 CRC
                local_path_crc = ''
                with open(abs_local_path, "rb") as f:
                    local_path_crc = ('%08x' % calculate_crc32(f.read()))
                    f.close()
                # 比对 CRC
                if remote_path_crc != local_path_crc:
                    err_msg = 'check upgrade file failed, local(%s)(%s). remote(%s)(%s) crc err' % \
                              (local_path_crc, abs_local_path, remote_path_crc, abs_remote_path)
                    self.__progress__.set_fail(err_msg)
                    logger.error(err_msg)
                    return False
                # 记录文件 CRC 值
                file_check_result.append({abs_remote_path:remote_path_crc})
            # 更新检查进度
            self.__progress__.increase(1, ("check: %s ok" % i))
        logger.info('Check end')
        logger.info('send file check list to remote')
        # 转换成 json
        file_check_json = json.dumps(file_check_result)
        # 传输文件

        def __file_cb(event, status, path, file_start_time, cur_size, total_size):
            return False

        try:
            file_check_path = remote_path.abspath('./file_check.json')
            self.__svc__.data_write(bytearray(file_check_json, encoding="utf8"), file_check_path, 0, False, __file_cb)
        except Exception as ex:
            err_msg = 'check upgrade file failed, write file check list to <%s> failed. Exception: %s' % (file_check_path, str(ex))
            self.__progress__.set_fail(err_msg)
            return False

        self.__progress__.set_success("check success")

    def progress(self):
        """
        获取进度对象
        """
        return self.__progress__

    def due_time(self):
        """
        获取截至时间
        :return: 时间（单位秒）
        """
        return self.__due_time__

    def quit(self):
        """
        设置当前处于退出状态
        :return: 无
        """
        self.__quit__ = True


def check_directory_upgrade_new(upgrade_info, config):
    """
    构建升级对象
    """
    return CheckUpgrade(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('check_dir_upgrade'), "new": check_directory_upgrade_new}
