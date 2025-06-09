# -*- coding: utf-8 -*-

import os
import time

from wearable.ota.progress import Progress, ProgressVC, ProgressPseudo
from wearable.ota import snowflake
from wearable.ota.context import Context
from wearable.files.delete import remove_all

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.RemoveUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class RemoveUpgrade(object):
    """
    文件/文件夹删除类
    :param __upgrade_info__: 升级信息，保存一份
    :param __progress__: 文件删除进度信息
    """

    class RemoveUpgradeProgressPseudo(ProgressPseudo):

        def increase(self, n, msgs=None):
            """
            重写 increase 方法，使其虚假进度增加的时候，附带一条消息
            :param n:
            :param msgs:
            :return:
            """
            super().increase(n, msgs='remove dir...')

    def __init__(self, upgrade_info, config):
        """
        :param upgrade_info:
        {
                "remote": system,          # 远端路径
        }
        """

        super().__init__()

        # 保存删除目录信息
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__id__ = snowflake.gid()
        print("init id: %s" % str(self.__id__))
        self.__ctx__ = Context()
        # 构建一个进度
        """
        制作假进度
        """
        self.__progress__ = self.RemoveUpgradeProgressPseudo(upgrade_info["remote"], int(upgrade_info["time"]))
        if 'time' in upgrade_info:
            self.__due_time__ = int(upgrade_info["time"])
        else:
            self.__due_time__ = 10
        # 是否处于退出状态
        self.__quit__ = False

    def run(self):
        """
        执行目录删除操作
        :return:
        """
        # 复位进度
        self.__progress__.reset()
        # 获取远端绝对路径
        upgrade_info = self.__upgrade_info__
        remote_path = os.path.join('/', upgrade_info["remote"]).replace('\\', '/')
        self.__progress__.set_start()
        # 先尝试获取上下文，检查是否已经进行过文件删除操作
        ctx = self.__ctx__.read()
        logger.info('context:%s' % (str(ctx)))
        logger.info('Start folder remove: %s' % remote_path)
        key = str(self.__id__)
        value = 'directory_remove'
        logger.info('key:%s value:%s' % (key, value))
        if isinstance(ctx, dict) and key in ctx:
            if ctx[key] == value:
                # 已经执行过删除，跳过删除
                self.__progress__.set_success()
                logger.info('Deleted, skip!')
                return
        # 执行删除动作
        try:
            logger.info('directory remove')
            remove_all(remote_path)
        except Exception as e:
            self.__progress__.set_fail()
            logger.error('file remove failed')
            raise e
        else:
            # 写入上下文，标记已经删除
            self.__ctx__.write(key, value)
            logger.info('context 2 :%s' % (str(self.__ctx__.read())))
            # 进度设置成功
            self.__progress__.set_success()
        logger.info('folder remove success')

    def progress(self):
        """
        获取进度对象
        """
        return self.__progress__

    def due_time(self):
        """
        返回预计执行时间
        :return:
        """
        return self.__due_time__

    def quit(self):
        """
        设置当前处于退出状态
        :return: 无
        """
        self.__quit__ = True


def remove_upgrade_new(upgrade_info, config):
    return RemoveUpgrade(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('directory_remove'), "new": remove_upgrade_new}
