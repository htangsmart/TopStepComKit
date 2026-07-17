# -*- coding: utf-8 -*-

import re
import time
import json
import traceback
import global_var
import os
from wearable.ota.progress import Progress
import logging
from urpc.services.file import *

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.CheckUpgradeAble'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def regular_verify(cond, args):
    """
    :param cond: 条件
    :param args: 参数
    :return:     结果
    """
    try:
        # cond is None, return pass.
        if cond is None:
            return True
        # args is None, return fail.
        if args is None:
            return False
        # regular to check cond and args.
        if re.search(str(cond), str(args)) is None:
            return False
        else:
            return True
    except Exception:
        logger.error('check upgrade able failed, regular verify failed.')
        logger.error(traceback.print_exc())
        return False


class CheckUpgradeAble(object):
    """
    查询设备是否可以进行升级类
    :param self.__progress__    : 进度容器，保存一组文件的进度信息
    :param self.__upgrade_info__: 类初始化入参，保存一份
    :param self.__config__      : 配置信息
    """

    def __init__(self, upgrade_info, config):
        """
        类初始化函数
        :param upgrade_info:
        """
        super(CheckUpgradeAble, self).__init__()
        self.__upgrade_info__ = upgrade_info
        self.__config__ = config
        self.__progress__ = Progress('check able', 1)
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
        svc = FileSvc(rpc, rpc.block_size - 58)
        # 最大重试次数
        retry = 5
        logger.info('Start check upgrade able')
        while retry > 0:
            try:
                result = rpc.exec_svc(1, "svc_ota_get_version", need_ack=False, need_rsp=True, timeout=3)
            except Exception:
                logger.error('check upgrade able failed, svc_ota_get_version cmd execute failed.')
                logger.error(traceback.print_exc())
                # retry count
                retry = retry - 1
                # 等待 1s 后再次重试
                time.sleep(1)
                # 继续重试
                continue
            try:
                check = self.check_upgrade_able(result)
                space = self.check_storage_able(svc)
            except Exception:
                logger.error('check upgrade able failed, an exception occurs.')
                logger.error(traceback.print_exc())
                # retry count
                retry = retry - 1
                # 等待 1s 后再次重试
                time.sleep(1)
                # 继续重试
                continue
                # 处理设备端的返回结果,成功返回，失败重试
            if check['result'] is True and space['result'] is True:
                error = 'check upgrade able success'
                self.__progress__.set_success(error)
            else:
                if check['result'] is False:
                    error = 'check upgrade able failed, [%s] is not pass.' % check['values']
                else:
                    error = 'check storage able failed, [%s] is not pass.' % space['values']
                self.__progress__.set_fail(error)
            # output the message.
            logger.error(error)
            return
        # 超过最大重试次数，仍然失败
        error = 'check upgrade able failed.'
        self.__progress__.set_fail(error)
        logger.error(error)

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

    def check_upgrade_able(self, result):
        """
        :param result: version info
        :return:
        """
        dict = {'firmware':'version.firmware','hardware':'version.hardware','ota_boot':'version.ota_boot','battery':'battery.level'}
        args = json.loads(result)
        cond = self.__upgrade_info__
        able = {'result': False, 'values':''}
        # check version
        for k, v in dict.items():
            cond_value = None
            args_value = None
            if k in cond:
                cond_value = cond[k]
            if v in args:
                args_value = args[v]
            verify = regular_verify(cond_value, args_value)
            if verify is False:
                logger.debug("%s check fail." % k)
                able['result'] = False
                able['values'] = v
                break
            else:
                logger.debug("%s check pass." % k)
                able['result'] = True
                able['values'] = v
        # return result
        return able

    def quit(self):
        """
        设置当前处于退出状态
        :return: 无
        """
        self.__quit__ = True

    def check_storage_able(self, svc):
        remote_same = 0
        local_total = 0
        able = {'result': True, 'values': ''}
        # 如果配置中没有 steps 对象，说明无需对容量进行检查，返回成功
        if 'steps' in self.__config__ is False:
            return able
        # 遍历 steps 对象数组，检查其中的 uses 对象
        for item in self.__config__['steps']:
            # 如果 steps 中没有 uses 对象，说明无需对容量进行检查，继续下一个
            if 'uses' in item is False:
                continue
            # 遍历 uses 对象，查找文件升级与目录升级步骤，检查待传输文件大小是否符合要求
            if item['uses'] == 'file_upgrade' or item['uses'] == 'directory_upgrade':
                # 如果 uses 对象中没有 filelist 数组或者没有 remote 属性，说明没有文件需要同步，继续下一个
                if 'filelist' in item is False or 'remote' in item is False:
                    continue
                # 如果 uses 对象中明确标识无需容量检查，则此步骤不检查，继续下一个
                if 'storageCheck' in item and item['storageCheck'] is False:
                    logger.debug("uses: {}, path: {}, not need check storage.".format(item['uses'], item['remote']))
                    continue
                # 检查此步骤是否使用了断点续传功能
                if item['uses'] == 'file_upgrade' or item['uses'] == 'directory_upgrade':
                    fs_continue = True
                else:
                    fs_continue = False
                logger.debug("uses: {}, path: {}, need check storage.".format(item['uses'], item['remote']))
                # 读取远端目录空间大小
                remote_file_path = os.path.join('/', item['remote']).replace('\\', '/')
                bsize, blocks, bfree = svc.fs_statfs(remote_file_path)
                # 读取成功，计算远端目录剩余空间
                if bsize > 0 and blocks > 0:
                    remote_free = bsize * bfree
                else:
                    able['result'] = True
                    able['values'] = 'remote {} get storage failed.'.format(remote_file_path)
                    return able
                logger.debug("path: {}, free: {} Bytes.".format(remote_file_path, remote_free))
                # 遍历文件列表，计算远端同名文件的文件大小
                file_list = item['filelist']
                for file in file_list:
                    locals_file_size = file['size']
                    remote_file_name = os.path.join('/', file['remote']).replace('\\', '/')
                    remote_file_size = svc.fs_file_size(remote_file_name, fs_continue)
                    logger.debug("file: {}, file_size: {} Bytes, remote_size: {} Bytes.".format(
                        remote_file_name, locals_file_size, remote_file_size)
                    )
                    remote_same += remote_file_size
                    local_total += locals_file_size
                # 如果远端文件剩余空间 + 同名文件的空间大于本地文件总大小 + 512，则空间充足，反则空间不足
                remote_total = remote_free + remote_same
                local_total = local_total + 512
                if remote_total > local_total:
                    able['result'] = True
                    able['values'] = 'path: {}, remote have: {} Bytes, need: {} Bytes, storage enough.'.format(
                        remote_file_path, remote_total, local_total)
                    logger.debug(able['values'])
                    return able
                else:
                    able['result'] = False
                    able['values'] = 'path: {}, remote have: {} Bytes, need: {} Bytes, storage not enough.'.format(
                        remote_file_path, remote_total, local_total)
                    logger.debug(able['values'])
                    return able
        # 遍历结束，返回成功
        return able


def check_upgrade_able_new(upgrade_info, config):
    """
    构建升级对象
    """
    return CheckUpgradeAble(upgrade_info, config)


def upgrade():
    """
    # 构建文件夹升级信息
    """

    return {"name": ('check_upgrade_able'), "new": check_upgrade_able_new}
