# -*- coding: utf-8 -*-
import json
import time
import traceback
import global_var
from wearable.ota.progress import Progress
import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.SetupUpgradeInfo'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def result_process(result):
    try:
        data = json.loads(result)
        logger.info("setup upgrade info result: %s" % data)
        if data['result'] == 'success':
            return True
        else:
            return False
    except Exception:
        logger.error('setup upgrade info result: %s, process failed.' % result)
        logger.error(traceback.print_exc())
        return False


class SetupUpgradeInfo(object):
    """
    设置升级信息类
    :param self.__progress__    : 进度容器，保存一组文件的进度信息
    :param self.__upgrade_info__: 类初始化入参，保存一份
    :param self.__config__      : 配置信息
    """

    def __init__(self, upgrade_info, config):
        """
        类初始化函数
        :param upgrade_info:
        """
        super(SetupUpgradeInfo, self).__init__()
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__progress__ = Progress('setup info', 1)
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
        # 最大重试次数
        retry = 5
        logger.info('Start setup upgrade info')
        while retry > 0:
            try:
                type = self.__upgrade_info__['type']
                data = self.__upgrade_info__['data']
                args = {'type': type, 'data': data}
                args = bytearray(json.dumps(args), encoding="utf8")
                logger.info("setup upgrade info: {}".format(args))
                result = rpc.exec_svc(1, "svc_ota_set_upgrade_info", args, need_ack=False, need_rsp=True, timeout=3)
            except Exception:
                logger.error('svc_ota_set_upgrade_info cmd execute failed')
                logger.error(traceback.print_exc())
                # retry count
                retry = retry - 1
                # 等待 1s 后再次重试
                time.sleep(1)
                # 再次重试
                continue
            # 处理设备端的返回结果,成功返回，失败重试
            if result_process(result) is True:
                self.__progress__.set_success()
                logger.info('setup upgrade info success.')
                return
            else:
                self.__progress__.set_fail()
                logger.info('setup upgrade info failed.')
        # 超过最大重试次数，仍然失败
        self.__progress__.set_fail()
        logger.info('setup upgrade info failed.')

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


def setup_upgrade_info_new(upgrade_info, config):
    """
    构建升级对象
    """
    return SetupUpgradeInfo(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('setup_upgrade_info'), "new": setup_upgrade_info_new}
