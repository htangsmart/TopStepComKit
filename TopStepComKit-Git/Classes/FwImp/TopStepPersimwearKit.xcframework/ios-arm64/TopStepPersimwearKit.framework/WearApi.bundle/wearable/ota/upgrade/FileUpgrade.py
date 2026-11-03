# -*- coding: utf-8 -*-
import os
import time
import traceback

import global_var
from urpc.services.file import *
from wearable.ota.progress import Progress, ProgressVC

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.FileUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class FileUpgrade(object):
    """
    文件同步类
    :param __upgrade_info__: 升级信息，保存一份
    :param __progress__: 文件进度信息
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
        # 构建每个文件的进度信息
        file_list = upgrade_info["filelist"]
        for fi in file_list:
            if fi["type"] == 'file' and fi["size"] > 0:
                # 为这个文件创建一个进度
                p = Progress(fi["remote"], fi["size"])
                # 将文件远端路径及文件进度关联起来
                file_mapping[fi["remote"]] = p
                # 将文件进度放到进度容器中
                vc.append(p, fi["size"])
        # 初始化类成员
        self.__progress__ = vc
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__file_mapping__ = file_mapping
        if 'time' in upgrade_info:
            self.__due_time__ = int(upgrade_info["time"])
        else:
            self.__due_time__ = 10
        # 是否处于退出状态
        self.__quit__ = False

    def run(self):
        file_mapping = self.__file_mapping__
        # 复位进度
        self.__progress__.reset()
        """
        升级运行函数
        """
        def __callback(event, status, path, file_start_time, cur_size, total_size):
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
            if path.startswith('/'):
                file = path[1:]
            else:
                file = path
            p = file_mapping[file]
            # 设置文件传输进度
            first_transmission = p.get() == 0
            if first_transmission:
                # 首次传输，开始进度统计
                p.set_start()
            msg = {
                "name": file,
                "total": total_size,
                "code": status,
                "progress": p.percentage(),
                "size": cur_size,
                "time": p.uses_time(),
                "remain_time": p.remain_time()}
            # 设置文件传输进度
            p.set(cur_size, msgs={"upgrade": 'file_upgrade', "file_info": msg})
            # 判断文件传输状态
            if event == 'onFailed':
                p.set_fail()
            elif event == 'onSuccess' and not p.is_complete():
                if p.get() == p.total():
                    p.set_success()
                else:
                    p.set_fail()
            elif event == 'onProcess':
                print('[DIR Sync][File] %s process. status:%s %d:%d' % (path, status, cur_size, total_size))
                # 是否需要退出runner
                if self.__quit__ is True:
                    return True
                else:
                    return False
            elif event == 'onComplete':
                if p.is_complete():
                    return True
                if p.get() == p.total:
                    p.set_success()
                else:
                    p.set_fail()
            return False
        # 获取升级信息
        upgrade_info = self.__upgrade_info__
        # 输出信息信息
        print('dir sync %s -> %s' % (upgrade_info['local'], upgrade_info['remote']))
        rpc = global_var.get('rpc')
        svc = FileSvc(rpc, rpc.block_size - 58)
        try:
            local = Path(upgrade_info['path'])
            remote = os.path.join('/', upgrade_info['remote']).replace('\\', '/')
            # 本地目录为文件还是目录
            if local.is_dir() is True:
                item_list = upgrade_info['filelist']
                # 遍历文件列表，开始传输
                for item in item_list:
                    local_path = Path(item['path'])
                    remote_path = os.path.join('/', item['remote']).replace('\\', '/')
                    # 开始传输文件
                    result = svc.fs_continue_write(local_path, remote_path, __callback)
                    # 如果传输失败，则退出循环
                    if result is False:
                        logger.error('local file %s write to remote file %s failed.' % (local_path, remote_path))
                        break
            else:
                # 开始传输文件
                result = svc.fs_continue_write(local, remote, __callback)
                # 如果传输失败输出调试信息
                if result is False:
                    logger.error('local file %s write to remote file %s failed.' % (local, remote))
        except Exception as ex:
            # 设置失败原因，用于调用者的查询与显示
            if (ex.__str__() != '') and (ex.__str__() is not None):
                self.__progress__.set_fail("file upgrade failed, " + ex.__str__())
            else:
                self.__progress__.set_fail('file upgrade failed, occurred the exceptions.')
            # 日志输出
            logger.error('local file %s write to remote file %s exceptions.' %(local, remote))
            logger.error(traceback.print_exc())
            raise Exception()

        if result is True:
            # 传输成功
            self.__progress__.set_success()
        else:
            # 传输失败
            self.__progress__.set_fail("file upgrade failed.")

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


def file_upgrade_new(upgrade_info, config):
    return FileUpgrade(upgrade_info, config)


def upgrade():
    # 构建文件升级信息
    return {"name": ('file_upgrade'), "new": file_upgrade_new}
