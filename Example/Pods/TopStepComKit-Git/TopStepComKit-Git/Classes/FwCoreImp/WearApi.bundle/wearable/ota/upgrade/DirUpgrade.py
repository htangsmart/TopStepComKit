# -*- coding: utf-8 -*-
import os

from wearable.ota.progress import Progress, ProgressVC
from wearable.files.push import push

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.DirUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

class DirUpgrade(object):
    """
    文件夹升级类
    :param __progress__: 进度容器，保存一组文件的进度信息
    :param __upgrade_info__: 类初始化入参，保存一份
    :param __config__: 保存配置信息
    :param __file_mapping__: 文件路径与进度关联表
    """

    def __init__(self, upgrade_info, config):
        """
        :param: upgrade_info 信息如下:
            {
                "local": key,           # 本地路径
                "remote": key,          # 远端路径
                "filelist": []
            }
            filelist 是一组文件列表，每个文件的必要描述如下，文件的路径是相对路径:
                {
                    "type":"file",
                    "local": "ota/rtthread.rbl"
                    "remote": "ota/rtthread.rbl"
                }
        """
        super().__init__()

        file_mapping = {}
        vc = ProgressVC(upgrade_info["remote"])
        # 传输总大小
        total_size = 0
        # 构建每个文件的进度信息
        file_list = upgrade_info["filelist"]
        for fi in file_list:
            if fi["type"] == 'file' and fi["size"] > 0:
                total_size = total_size + fi["size"]
                # 为这个文件创建一个进度
                p = Progress(fi["remote"], fi["size"])
                # 将文件远端路径及文件进度关联起来
                file_mapping[os.path.normpath(os.path.join('/', fi["remote"]))] = p
                # 将文件进度放到进度容器中
                vc.append(p, fi["size"])
        # 初始化类成员
        self.__progress__ = vc
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__file_mapping__ = file_mapping
        self.__total_size__ = total_size
        if 'time' in upgrade_info:
            self.__due_time__ = int(upgrade_info["time"])
        else:
            self.__due_time__ = 10
        # 是否处于退出状态
        self.__quit__ = False

    def run(self):
        """
        升级运行函数
        """
        file_mapping = self.__file_mapping__
        # 复位进度
        self.__progress__.reset()

        def __callback(event, status, path, file_start_time, cur_size, total_size):
            nonlocal file_mapping
            result = False
            """
            升级进度回调函数
            :param event: 'onFailed' 'onComplete' 'onSuccess' 'onProcess'
            :param status: 200: "OK", 500: "general error",
            :param path: 远端路径
            :param file_start_time: 开始时间(秒)
            :param cur_size:当前传输大小
            :param total_size:总大小

            "file":            当前正常传输文件状态
            {
                "name"：        文件名
                "total"：       文件大小
                "code":         错误码
                "progress":     当前文件传输进度
                "size"          传输大小
                "time"：        传输时间
                "remain_time":  剩余时间
            }
            """
            path = os.path.normpath(str(path).replace('\\', '/'))
            p = file_mapping[path]
            # 设置文件传输进度
            first_transmission = p.get() == 0
            if first_transmission:
                # 首次传输，开始进度统计
                p.set_start()
            # 构建消息
            msg = {
                "name": path,
                "total": total_size,
                "code": status,
                "progress": p.percentage(),
                "size": cur_size,
                "time": p.uses_time(),
                "remain_time": p.remain_time()}
            # 设置完成量
            p.set(cur_size, msgs={"upgrade": 'directory_upgrade', "file_info": msg})
            # 判断文件传输状态
            if event == 'onFailed':
                logger.error('[DIR Sync][File] %s failed. status:%s %d:%d' % (path, status, cur_size, total_size))
                p.set_fail()
            elif event == 'onSuccess' and (not p.is_complete()):
                if p.get() == p.total():
                    logger.info('[DIR Sync][File] %s success. %d' % (path, total_size))
                    p.set_success()
                else:
                    logger.info('[DIR Sync][File] %s Not really successful. total_size:%d %d:%d' % (path, total_size, p.get(), p.total()))
                    p.set_fail()
            elif event == 'onProcess':
                if first_transmission:
                    logger.info('[DIR Sync][File] %s start.' % path)
                else:
                    logger.debug('[DIR Sync][File] %s process. status:%s %d:%d' % (path, status, cur_size, total_size))
                # 是否需要退出runner
                if self.__quit__ is True:
                    result = True
                else:
                    result = False
            elif event == 'onComplete':
                if p.is_complete():
                    return result
                if p.get() == p.total():
                    p.set_success()
                else:
                    p.set_fail()
            return result

        # 获取升级信息
        upgrade_info = self.__upgrade_info__
        # 输出信息信息，传输整个目录
        local_path = upgrade_info['path']
        remote_path = os.path.join('/', upgrade_info['remote']).replace('\\', '/')
        logger.info('Start folder synchronization: %s -> %s' % (local_path, remote_path))
        push(local_path, remote_path, True, continue_write=True, callback=__callback)
        if self.__total_size__ == 0:
            logger.info('empty dir %s. set success' % (remote_path))
            self.__progress__.set_success()
        if self.__progress__.is_failed():
            self.__progress__.set_fail("directory upgrade failed.")
        logger.info('End of file synchronization')

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


def directory_upgrade_new(upgrade_info, config):
    """
    构建升级对象
    """
    return DirUpgrade(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('directory_upgrade'), "new": directory_upgrade_new}
