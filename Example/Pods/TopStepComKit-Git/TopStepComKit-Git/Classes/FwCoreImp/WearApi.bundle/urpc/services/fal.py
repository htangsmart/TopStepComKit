#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-25     tyustli      the first version
#

from urpc.src.ffi import *
import os
import threading
import time

from .svc_utils import *

LOG_LVL = logging.INFO
LOG_TAG = 'fal'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class FalSvc:
    def __init__(self, rpc, block_size):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        self.block_size = block_size
        self.erase_thread = threading.Thread(target=self.fal_erase_process)
        self.erase_lock = threading.Lock()
        self.erase_size = 0
        logger.debug("fal Init ok")

    def fal_erase_process(self):
        timeout = self.erase_size / 1000 / 50 + 1
        list_char = ["\\", "|", "/", "-", "|", '-']
        for i in range(int(timeout)):
            with self.erase_lock:
                index = i % len(list_char)
                print("\rerasing ... {}".format(list_char[index]), end="", flush=True)
            time.sleep(0.05)

    def fal_probe(self, input_name):
        part_name = Arg(U8 | ARRAY, bytearray(input_name + '\0', encoding="utf8"))
        result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_find", [part_name], need_ack=False, need_rsp=True, timeout=10)
        if result.value != 0:
            logger.debug("fal probe {0} ok.".format(input_name))
        else:
            logger.error("fal probe {0} fail.".format(input_name))
        return result

    def fal_erase(self, input_part, input_addr, input_size):
        addr = Arg(U32, input_addr)
        size = Arg(U32, input_size)
        self.erase_size = input_size
        logger.debug("fal erase start.")

        self.erase_thread.start()
        start_time = time.time()
        result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_erase", [input_part, addr, size], need_ack=False,
                                        need_rsp=True, timeout=input_size/1000/50 + 1)
        self.erase_lock.acquire()
        print("\rerase complate.", end='', flush=True)
        used_time = time.time() - start_time
        print("\nerase speed=", StrOfSize(int(input_size / used_time)), "/s (", StrOfSize(input_size), "in",
              int(used_time * 1000) / 1000, "s )")
        logger.debug("fal erase end.")
        return result

    def fal_write_data(self, input_part, input_addr, data):
        """
        将一片数据写入到指定的分区中
        :param input_part:指定分区, 一般为 fal_probe 函数的返回值
        :param input_addr:指定地址
        :param data:数据
        :return:成功写入的长度
        """

        total = len(data)
        offset = 0

        while total > 0:
            # 计算单次写入数据长度
            if total < self.block_size:
                write_size = total
            else:
                write_size = self.block_size

            # 构建执行参数
            addr = Arg(U32, offset + input_addr)
            buffer = Arg(U8 | ARRAY, data[offset:offset+write_size])
            buffer_len = Arg(U32, buffer.value_len)
            # 执行远端函数调用
            result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_write",
                                            [input_part, addr, buffer, buffer_len],
                                            need_ack=False, need_rsp=True, timeout=10)
            # 检查数据是否写入成功写入
            if result.value < 0:
                return offset

            total -= write_size
            offset += write_size

        return offset

    def fal_read_data(self, input_part, input_addr, input_size):
        """
        从指定分区中读取数据
        :param input_part:指定分区，一般为 fal_probe 函数的返回值
        :param input_addr:分区偏移地址
        :param input_size:分区大小
        :return:读取到的数据
        """

        total = input_size
        offset = 0
        data_buffer = []

        while total > 0:
            if total < self.block_size:
                read_size = total
            else:
                read_size = self.block_size

            # 构建执行参数
            addr = Arg(U32, offset + input_addr)
            buffer = Arg(U8 | ARRAY | EDITABLE, list(range(read_size)))
            buffer_len = Arg(U32, buffer.value_len)
            # 执行远端函数调用
            result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_read",
                                            [input_part, addr, buffer, buffer_len],
                                            need_ack=False, need_rsp=True, timeout=10)
            # 检查是否成读取数据
            if result.value < 0:
                return data_buffer

            total -= read_size
            offset += read_size
            data_buffer.extend(buffer.value)

        return data_buffer

    def fal_erase_data(self, input_part, input_addr, input_size):
        """
        擦除指定分区中的数据
        :param input_part: 指定分区，一般为 fal_probe 函数的返回值
        :param input_addr: 擦除起始地址
        :param input_size: 擦除的大小
        :return: 实际擦除的大小
        """

        # 构建执行参数
        addr = Arg(U32, input_addr)
        size = Arg(U32, input_size)
        timeout = input_size / 1000 / 50 + 1
        # 执行远程调用
        result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_erase", [input_part, addr, size],
                                        need_ack=False, need_rsp=True, timeout=timeout)
        # 检查返回值
        if result.value < 0:
            return 0
        else:
            return input_size

    def fal_write_file(self, input_part, input_addr, file_path):
        try:
            with open(file_path, "rb") as f:
                file = f.read()
        except Exception as e:
            logger.error("fal open file {0} fail.".format(file_path))

        # file = open(file_path, mode='rb')
        addr = Arg(U32, input_addr)
        count = os.path.getsize(file_path)
        totle = count
        offset = 0
        start_time = time.time()
        logger.debug("fal write start.")

        while count > 0:
            if count < self.block_size:
                write_size = count
            else:
                write_size = self.block_size
            count -= write_size
            fal_buff = file[offset:offset+write_size]
            buffer = Arg(U8 | ARRAY, fal_buff)
            buffer_len = Arg(U32, buffer.value_len)
            result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_write", [input_part, addr, buffer, buffer_len], need_ack=False,
                                   need_rsp=True, timeout=10)

            if result.value < 0:
                return result

            addr.value += buffer.value_len
            offset += write_size
            process_bar((totle - count) / totle, start_str='', total_length=15)
        used_time = time.time() - start_time
        print("\nwrite speed=", StrOfSize(int(totle / used_time)), "/s (", StrOfSize(totle), "in",
              int(used_time * 1000) / 1000, "s )")
        logger.debug("fal write end.")

        return result

    def fal_read_file(self, input_part, input_addr, input_size):
        offset = input_addr
        totle = input_size
        r_buffer_list = []
        start_time = time.time()

        logger.debug("fal read start.")

        while input_size > 0:
            if input_size < self.block_size:
                read_size = input_size
            else:
                read_size = self.block_size

            # addr offset
            addr = Arg(U32, offset)

            input_size -= read_size
            buffer = Arg(U8 | ARRAY | EDITABLE, list(range(read_size)))
            buffer_len = Arg(U32, buffer.value_len)
            result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_read", [input_part, addr, buffer, buffer_len], need_ack=False,
                                            need_rsp=True, timeout=10)
            if result.value < 0:
                logger.error("fal read fail.")
                return result

            offset += read_size
            r_buffer_list.extend(buffer.value)
            process_bar((totle - input_size) / totle, start_str='', total_length=15)

        used_time = time.time() - start_time
        print("\nread speed=", StrOfSize(int(totle / used_time)), "/s (", StrOfSize(totle), "in",
              int(used_time * 1000) / 1000, "s )")

        logger.debug("fal read end.")

        return result, r_buffer_list

    def fal_crc32_calculate(self, input_part, input_addr, input_size):
        addr = Arg(U32, input_addr)
        size = Arg(U32, input_size)
        self.erase_size = input_size
        logger.debug("fal calculate crc32 start.")
        start_time = time.time()
        result = self.rpc.exec_ffi_func(self.daemon_id, "fal_crc32_calculate", [input_part, addr, size], need_ack=False,
                                        need_rsp=True, timeout=60)
        logger.debug("crc32 calculate size: 0x%X, spend time: %d", input_size, time.time() - start_time)
        logger.debug("fal calculate crc32 end.")
        return result

    def fal_write_local_file(self, input_file, input_part, input_offset, timeout=60):
        offset = Arg(U32, input_offset)
        file = Arg(U8 | ARRAY, bytearray(input_file + '\0', encoding="utf8"))
        part = Arg(U8 | ARRAY, bytearray(input_part + '\0', encoding="utf8"))
        logger.debug("fal write local file start, timeout: %d", timeout)
        start_time = time.time()
        result = self.rpc.exec_ffi_func(self.daemon_id, "fal_partition_write_file", [file, part, offset],
                                        need_ack=False, need_rsp=True, timeout=timeout)
        logger.debug("fal write local file result is %d, spend time: %d", result.signed(), time.time() - start_time)
        logger.debug("fal write local file end.")
        return result
