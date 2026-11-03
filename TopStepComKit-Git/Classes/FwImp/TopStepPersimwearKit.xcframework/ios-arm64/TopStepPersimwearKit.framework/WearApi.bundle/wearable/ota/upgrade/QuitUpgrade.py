# -*- coding: utf-8 -*-

import time
from urpc.src import *
from urpc.src.ffi import *
import global_var
from wearable.ota.progress import Progress
import traceback
import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.QuitUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class QuitUpgrade(object):
    """
    退出升级模式类
    :param __progress__: 进度容器，保存一组文件的进度信息
    :param __upgrade_info__: 类初始化入参，保存一份
    """

    def __init__(self, upgrade_info, config):
        """
        类初始化函数
        :param upgrade_info:
        """
        super(QuitUpgrade, self).__init__()
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__progress__ = Progress('quit ota', 1)
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
        logger.info('Start quit upgrade mode')
        while retry >= 0:
            try:
                result = rpc.exec_ffi_func(1, "svc_ota_get_upgrade_state", need_ack=False, need_rsp=True, timeout=3)
            except Exception as ex:
                logger.info('exception occurred. error:%s' % (ex.__str__()))
                logger.info(traceback.format_exc())
                retry = retry - 1
                # 等待 3s 后再次重试
                time.sleep(3)
                continue
            # 返回值为0，说明已经不处于升级模式了，大于0，说明依然处于升级模式
            if result.signed() == 0:
                logger.info('quit upgrade mode success!')
                self.__progress__.set_success()
                return
            else:
                try:
                    if self.need_reboot() is True:
                        reboot = Arg(U8, value=True)
                    else:
                        reboot = Arg(U8, value=False)
                    rpc.exec_ffi_func(1, "svc_ota_set_upgrade_quit", [reboot], need_ack=False, need_rsp=True, timeout=3)
                except Exception as ex:
                    logger.info('exception occurred. error:%s' % (ex.__str__()))
                    logger.info(traceback.format_exc())
                # 等待 3s 后再次重试
                time.sleep(3)
        # 超过最大重试次数，仍然失败
        self.__progress__.set_fail('quit upgrade mode failed.')
        logger.info('quit upgrade mode failed.')

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

    def need_reboot(self):
        if 'type' in self.__upgrade_info__:
            if self.__upgrade_info__['type'] == 'reboot':
                result = True
            else:
                result = False
        else:
            result = False
        return result

def quit_upgrade_new(upgrade_info, config):
    """
    构建升级对象
    """
    return QuitUpgrade(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('quit_upgrade_mode'), "new": quit_upgrade_new}
