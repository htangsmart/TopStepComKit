# -*- coding: utf-8 -*-

import os
import time
import json

import global_var
from wearable.ota.progress import Progress, ProgressVC, ProgressPseudo
from wearable.ota.utils import ota_compare_version

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.EnterUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class EnterUpgrade(object):
    """
    进入升级模式类
    :param __progress__: 进度容器，保存一组文件的进度信息
    :param __upgrade_info__: 类初始化入参，保存一份
    """

    def __init__(self, upgrade_info, config):
        """
        类初始化函数
        :param upgrade_info:
        """
        super(EnterUpgrade, self).__init__()
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__progress__ = Progress('enter ota', 1)
        if 'time' in upgrade_info:
            self.__due_time__ = int(upgrade_info["time"])
        else:
            self.__due_time__ = 5
        # 是否处于退出状态
        self.__quit__ = False

    def run(self):
        """
        执行进入升级函数:
        """
        # 查询升级模式
        self.__progress__.reset()
        self.__progress__.set_start()
        rpc = global_var.get('rpc')
        retry = 30
        logger.info('Start entering upgrade mode')
        while retry > 0:
            # 首先设置进入OTA状态
            try:
                # 查询是否需要重启
                reboot = self.need_reboot(rpc)
                # 如果需要重启，调用state接口，否则调用choke接口
                if reboot is True:
                    rpc.exec_ffi_func(1, "svc_ota_set_upgrade_state", need_ack=False, need_rsp=True, timeout=3)
                else:
                    rpc.exec_ffi_func(1, "svc_ota_set_upgrade_choke", need_ack=False, need_rsp=True, timeout=3)
            except Exception:
                logger.warning('enter upgrade mode error. retry.')
            # 其次读取OTA状态信息
            try:
                result = rpc.exec_ffi_func(1, "svc_ota_get_upgrade_state", need_ack=False, need_rsp=True, timeout=3).signed()
            except Exception:
                # 出现异常，设置结果为0，继续重试
                result = 0
                logger.warning('get upgrade state error. retry.')
            # 最后检查当前是否处于资源传输状态
            if result == 2:
                logger.info('set upgrade mode success!')
                self.__progress__.set_success()
                # 已经处于升级模式，函数退出
                return
            else:
                logger.warning('Is not currently in upgrade mode! %d' % (int(result)))
            # 重试次数减1
            retry = retry - 1
            # 等待 3s 后再次重试
            time.sleep(3)
        # 超过最大重试次数，仍然失败
        self.__progress__.set_fail()
        logger.info('set upgrade mode failed!')

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

    def need_reboot(self, rpc):
        """
        查询设备端是否需要重启
        :return:
        """
        # 查询升级包是否要求设备重启
        if 'deviceNeedReboot' in self.__config__:
            var1 = self.__config__['deviceNeedReboot']
        else:
            var1 = True
        # 查询设备端版本号
        values = rpc.exec_svc(1, "svc_ota_get_version", need_ack=False, need_rsp=True, timeout=3)
        json_obj = json.loads(values.decode('utf-8'))
        if 'version.ota_boot' in json_obj:
            version = json_obj['version.ota_boot']
        else:
            version = '1.0.0'
        # 比较版本号
        var2 = ota_compare_version(version, "2.0.0")
        # 生成返回值
        if (var1 == False) and (var2 >= 0):
            result = False
        else:
            result = True
        # 生成返回结果
        return result

    def quit(self):
        """
        设置当前处于退出状态
        :return: 无
        """
        self.__quit__ = True


def enter_upgrade_new(upgrade_info, config):
    """
    构建升级对象
    """
    return EnterUpgrade(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('enter_upgrade_mode'), "new": enter_upgrade_new}
