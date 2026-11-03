# -*- coding: utf-8 -*-

import os
import json
import traceback
import global_var
from urpc.services.fal import FalSvc
from urpc.services.file import Path, FileSvc
from wearable import path
from mcf.mcf_utils import calculate_crc32

from wearable.ota.progress import Progress, ProgressVC

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.FALUpgrade'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def align(n, a):
    return (n + n - 1) & ~(a - 1)


def fal_probe(fal, partition):
    """
    查找分区
    :param fal: 分区操作对象
    :param partition: 分区名
    :return: 分区对象
    """
    # 尝试挂载分区
    logger.info('fal try probe %s' % partition)
    result = fal.fal_probe(partition)
    if result.value == 0:
        # 返回值为 0，表示未查找到该分区
        raise RuntimeError('Not find partition. %s' % partition)
    else:
        logger.info('fal probe %s success, handle:%x' % (partition, result.value))
        return result


def fal_diff(fal, handle, data, erase_size, p):
    """
    升级前置准备，预处理函数, 这里先检查了分区差异项
    :param fal: 分区操作对象
    :param handle: 分区对象
    :param data:待升级的数据
    :param erase_size: 擦除大小
    :param p: 进度对象
    :return: 数据差异列表
    """
    # 构建数据完整性列表，用于记录各个扇区数据是否与 data 一致
    check_list = []
    offset = 0
    total = len(data)

    # 进度开始
    p.set_start()
    logger.info('FAL prepare start')
    # 最小检查块，为一个擦除块的大小
    while total > 0:
        check_size = erase_size
        if total < check_size:
            check_size = total
        # 校验数据
        remote_crc = fal.fal_crc32_calculate(handle, offset, check_size).value
        local_data = data[offset:offset + check_size]
        local_crc = calculate_crc32(local_data)
        # 记录差异
        check_list.append({"offset": offset, "size": check_size, "remote_crc": remote_crc,
                           "local_crc": local_crc, "local_data": local_data})

        # TODO: 调试等级修改成 debug
        logger.info(
            'FAL prepare: off:%d size:%d remote_crc:%x local_crc:%x' % (offset, check_size, remote_crc, local_crc))
        # 计算下一次偏移量
        total -= check_size
        offset += check_size

        # 更新进度值
        p.increase(1, ('fal check %d' % offset))

    # 设置该进度已经完成
    p.set_success()

    logger.info('FAL prepare end')
    # 记录检查结果
    return check_list


def fal_upgrade(fal, handle, data, erase_size, check_list, p):
    """
    执行升级功能
    :param fal: 分区操作对象
    :param handle: 分区对象
    :param data:待升级的数据
    :param erase_size: 擦除大小
    :param p: 进度对象
    :param check_list:前置检查列表
    :return:
    """

    # 校验 check_list 是否完整
    total = 0
    for item in check_list:
        if total != item["offset"]:
            # 偏移值异常
            raise RuntimeError('Offset error. %d:%d' % (total, item["offset"]))
        if erase_size != item["size"] and item != check_list[-1]:
            # 块大小异常
            raise RuntimeError('Block size error. %d:%d' % (erase_size, item["size"]))
        total += item["size"]
    if len(data) != total:
        raise RuntimeError('Total file size error. %d:%d', len(data), total)

    # 查找差异项
    diff_list = []
    for item in check_list:
        # TODO: 合并连续的差异项?
        if item["remote_crc"] != item["local_crc"]:
            logger.info('diff sector: offset: %d, size: %d, remote_crc: %x, local_crc: %x' %
                        (item["offset"], item["size"], item["remote_crc"], item["local_crc"]))
            diff_list.append(item)

    # 进度开始
    p.set_start()
    # 设置进度
    p.set(len(check_list) - len(diff_list))

    if len(diff_list) == 0:
        logger.info('wOw!! The local is consistent with the remote, and synchronization is not required')

    # 同步差异项
    for item in diff_list:
        offset = item["offset"]
        size = item["size"]
        write_data = data[offset:offset + size]
        # 擦除数据
        logger.info('erase pos:%d len:%d' % (offset, size))
        fal.fal_erase_data(handle, offset, size)
        # 写入数据
        logger.info('write pos:%d len:%d' % (offset, len(write_data)))
        fal.fal_write_data(handle, offset, write_data)
        # 更新进度值
        p.increase(1, ('fal upgrade %d' % offset))

    # 设置该进度已经完成
    p.set_success()
    logger.info('fal upgrade success')


def fal_check(fal, handle, data, p):
    """
    升级分区与升级数据完整性校验
    :return: True: 校验成功 False: 校验失败
    """
    # 完整性校验
    offset = 0
    size = len(data)
    logger.info('check remote pos:%d len:%d' % (offset, size))
    # 进度开始
    p.set_start()
    remote_crc = fal.fal_crc32_calculate(handle, offset, size).value
    local_crc = calculate_crc32(data)
    logger.info('remote_crc:%x local_crc:%x' % (remote_crc, local_crc))
    if remote_crc != local_crc:
        raise RuntimeError('remote_crc:%x != local_crc:%x' % (remote_crc, local_crc))
    # 成功
    p.set_success()
    logger.info('check remote success. remote_crc:%08x  local_crc:%08x' % (remote_crc, local_crc))


def file_write(file, local_file, remote_file, data, p):
    """
    本地文件同步至远端
    :param local_file: 本地文件
    :param remote_file: 远端文件
    :param data: 文件数据
    :param p: 此步骤进度对象
    :return:
    """

    def __callback(event, status, path, start_time, cur_size, total_size):
        # 判断文件传输状态
        if event == 'onFailed':
            err = "fal upgrade failed. file: %s, status: %s, %d:%d" % (path, status, cur_size, total_size)
            p.set_fail(err)
            logger.error(err)
        elif event == 'onSuccess':
            err = "fal upgrade success."
            p.set_success(err)
            logger.debug(err)
        elif event == 'onProcess':
            logger.debug('fal upgrade process. file: %s, status: %s, %d:%d' % (path, status, cur_size, total_size))
            msg = {
                "name": path,
                "total": total_size,
                "code": status,
                "progress": p.percentage(),
                "size": cur_size,
                "time": p.uses_time(),
                "remain_time": 0
            }
            p.set(cur_size, msgs={"upgrade": 'fal_upgrade', "file_info": msg})
        return False

    try:
        local = Path(local_file)
        remote = os.path.join('/', remote_file).replace('\\', '/')
        total = len(data)
        p.set_total(total)
        p.set_start()
        file.fs_continue_write(local, remote, __callback)
    except Exception:
        error = 'fal upgrade failed, local file %s write to remote file %s error.' % (local, remote)
        p.set_fail(error)
        logger.error(error)
        logger.error(traceback.print_exc())


def file_upgrade(fal, remote_file, remote_part, data, p):
    """
    远端分区离线升级
    :param fal: fal分区对象
    :param remote_file: 远端文件
    :param remote_part: 远端分区
    :param data: 文件数据
    :param p: 此步骤进度对象
    :return:
    """

    try:
        offset = 0
        length = len(data)
        remote = os.path.join('/', remote_file).replace('\\', '/')
        # 超时时间计算，假设速度为：4K/s
        timeout = (length / 4096) + 1
        p.set_start()
        result = fal.fal_write_local_file(remote, remote_part, offset, timeout=timeout)
        if result.signed() == 0:
            p.set_success()
        else:
            err = 'fal upgrade failed, remote file %s write to remote fal part %s error.' % (remote, remote_part)
            p.set_fail(err)
    except Exception:
        error = 'fal upgrade failed, remote file %s write to remote fal part %s error.' % (remote, remote_part)
        p.set_fail(error)
        logger.error(error)
        logger.error(traceback.print_exc())


def file_verify(fal, remote_part, data):
    """
    本地文件与远端分区数据对比
    :param fal: fal分区对象
    :param remote_part: 远端分区
    :param data: 文件数据
    :return: True 数据一致, False 数据不一致
    """

    try:
        offset = 0
        length = len(data)
        part = fal_probe(fal, remote_part)
        remote_crc = fal.fal_crc32_calculate(part, offset, length).value
        local_crc = calculate_crc32(data)
        if remote_crc != local_crc:
            result = False
            logger.info('remote part %s verify remote:%x != local:%x, need upgrade.' % (remote_part, remote_crc, local_crc))
        else:
            result = True
            logger.info('remote part %s verify remote:%x == local:%x, not need upgrade.' % (remote_part, remote_crc, local_crc))
    except Exception:
        result = False
        logger.error('remote part %s verify crc error.' % (remote_part))
        logger.error(traceback.print_exc())
    # 返回校验结果
    return result


class FALUpgrade(object):
    """
    FAL 升级类，提供 FAL 类型的文件升级
    :param __upgrade_info__: 保存升级信息
    :param __config__: 保存配置信息
    :param __partition__: 分区句柄
    :param __erase_size__: 分区最小擦除大小
    :param __progress__: 进度
    """
    # 最小擦除大小
    __erase_size__ = 4096

    def __init__(self, upgrade_info, config):
        """
        :param: upgrade_info 信息如下:
            {
                "local": 'xx',           # 本地文件相对路径
                "path": '/xx/xx'         # 本地文件存放绝对路径
                "remote": key,           # 远端分区名
            }
        """
        super().__init__()
        # 读取本地 fal 分区固件
        with open(upgrade_info["path"], "rb") as f:
            self.__data__ = f.read()
            f.close()
        # 构建进度对象
        p = align(len(self.__data__), self.__erase_size__) / self.__erase_size__
        self.__prepare_progress__ = Progress("FAL Prepare", p)
        self.__upgrade_progress__ = Progress("FAL Upgrade", p)
        self.__check_progress__ = Progress("FAL Check", p)
        self.__progress__ = ProgressVC('FAL')
        # 构建传输对象
        rpc = global_var.get('rpc')
        self.__fal__ = FalSvc(rpc, rpc.block_size - 58)
        self.__fd__ = FileSvc(rpc, rpc.block_size - 58)
        self.__rpc__ = rpc
        # 保存相关信息
        self.__remote__ = str(upgrade_info["remote"])
        self.__remote_file__ = str(upgrade_info["local"])
        self.__upgrade_info__ = upgrade_info
        self.__local__ = str(upgrade_info["path"])
        if 'type' in upgrade_info:
            self.__type__ = str(upgrade_info["type"])
        else:
            self.__type__ = 'fal'
        self.__check_list__ = None
        self.__progress_dict__ = None
        if 'time' in upgrade_info:
            self.__due_time__ = int(upgrade_info["time"])
        else:
            self.__due_time__ = len(self.__data__) / 4096
        # 是否处于退出状态
        self.__quit__ = False

    def run(self):
        """
        执行分区升级动作
        """
        if self.__rpc__.compare_version("2.4.4") > 0:
            logger.info("The current version is later than 2.4.4, fal use the <offline_upgrade> interface.")
            self.offline_upgrade()
        else:
            logger.info("The current version is earlier than 2.4.4, fal use the <online_upgrade> interface.")
            self.online_upgrade()
        # 检查整体进度是否成功
        if not self.__progress__.is_success():
            error = 'fal upgrade failed.'
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

    def quit(self):
        """
        设置当前处于退出状态
        :return: 无
        """
        self.__quit__ = True

    def online_upgrade(self):
        try:
            self.__progress__.append(self.__prepare_progress__, 20)
            self.__progress__.append(self.__upgrade_progress__, 60)
            self.__progress__.append(self.__check_progress__, 20)
            # 复位进度
            self.__progress__.reset()
            # 挂载分区
            fal_handle = fal_probe(self.__fal__, self.__remote__)
            # 查找待升级的区域
            check_list = fal_diff(self.__fal__, fal_handle, self.__data__, self.__erase_size__, self.__prepare_progress__)
            # 分区升级
            fal_upgrade(self.__fal__, fal_handle, self.__data__, self.__erase_size__, check_list, self.__upgrade_progress__)
            # 完整性校验
            fal_check(self.__fal__, fal_handle, self.__data__, self.__check_progress__)
        except Exception:
            error = 'fal upgrade failed, local file %s write to remote part %s error.' %(self.__local__, self.__remote__)
            self.__progress__.set_fail(error)
            logger.error(error)
            logger.error(traceback.print_exc())

    def offline_upgrade(self):
        # 远端数据与本地数据校验，数据无差异，无需升级
        if file_verify(self.__fal__, self.__remote__, self.__data__) is True:
            self.__progress__.set_success()
            return
        # 远端数据与本地数据校验，数据有差异，进行升级
        try:
            self.__progress__.append(self.__prepare_progress__, 80)
            self.__progress__.append(self.__upgrade_progress__, 10)
            self.__progress__.append(self.__check_progress__, 10)
            # 复位进度
            self.__progress__.reset()
            # 本地文件传输至远端
            file_write(self.__fd__, self.__local__, self.__remote_file__, self.__data__, self.__prepare_progress__)
            # 分区升级
            file_upgrade(self.__fal__, self.__remote_file__, self.__remote__, self.__data__, self.__upgrade_progress__)
            # 挂载分区
            fal_part = fal_probe(self.__fal__, self.__remote__)
            # 完整性校验
            fal_check(self.__fal__, fal_part, self.__data__, self.__check_progress__)
        except Exception:
            error = 'fal upgrade failed, local file %s write to remote part %s error.' %(self.__local__, self.__remote__)
            self.__progress__.set_fail(error)
            logger.error(error)
            logger.error(traceback.print_exc())


def fal_upgrade_new(upgrade_info, config):
    """
    构造升级对象
    :return:
    """
    return FALUpgrade(upgrade_info, config)


def upgrade():
    # 文件升级信息
    return {"name": ('fal_upgrade'), "new": fal_upgrade_new}
