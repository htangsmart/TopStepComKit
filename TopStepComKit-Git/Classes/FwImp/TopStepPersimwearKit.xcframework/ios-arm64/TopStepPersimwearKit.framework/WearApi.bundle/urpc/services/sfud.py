#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-25     BalanceTWK   the first version
#

import logging

import os
import time

from .svc_utils import *

LOG_LVL = logging.INFO
LOG_TAG = 'sfud'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class sfudSvc:
    def __init__(self, rpc, block_size):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        self.block_size = block_size
        logger.debug("SFUD Init ok")

    def sfud_probe(self, name):
        sfud_buff = bytearray("urpc_d\0" + ' ' * 3 + name + "\0", encoding="utf8")
        self.rpc.exec_svc(self.daemon_id, "urpc_rsp_sfud_probe", sfud_buff, need_ack=False, need_rsp=True, timeout=10)
        logger.debug("sfud_probe ok")

    def sfud_erase(self, addr, size):
        sfud_buff = bytearray()
        sfud_buff.append(addr & 0x000000FF)
        sfud_buff.append((addr & 0x0000FF00) >> 8)
        sfud_buff.append((addr & 0x00FF0000) >> 16)
        sfud_buff.append((addr & 0xFF000000) >> 24)
        sfud_buff.append(size & 0x000000FF)
        sfud_buff.append((size & 0x0000FF00) >> 8)
        sfud_buff.append((size & 0x00FF0000) >> 16)
        sfud_buff.append((size & 0xFF000000) >> 24)
        self.rpc.exec_svc(self.daemon_id, "urpc_rsp_sfud_erase", sfud_buff, need_rsp=True, timeout=10)
        logger.debug("sfud_erase ok")

    def sfud_write_file(self, addr, file_path):
        file = open(file_path, mode='rb')
        count = os.path.getsize(file_path) - file.tell()
        totle = count
        start_time = time.time()
        logger.debug("sfud start write")
        while count > 0:
            if count < self.block_size:
                self.block_size = count
            count -= self.block_size
            sfud_buff = bytearray()
            sfud_buff.append(addr & 0x000000FF)
            sfud_buff.append((addr & 0x0000FF00) >> 8)
            sfud_buff.append((addr & 0x00FF0000) >> 16)
            sfud_buff.append((addr & 0xFF000000) >> 24)
            sfud_buff.append(self.block_size & 0x000000FF)
            sfud_buff.append((self.block_size & 0x0000FF00) >> 8)
            sfud_buff.append((self.block_size & 0x00FF0000) >> 16)
            sfud_buff.append((self.block_size & 0xFF000000) >> 24)
            sfud_buff += file.read(self.block_size)
            self.rpc.exec_svc(self.daemon_id, "urpc_rsp_sfud_write", sfud_buff, need_ack=False, need_rsp=True, timeout=10)
            addr += self.block_size
            process_bar((totle-count)/totle, start_str='', total_length=15)
        file.close()
        end_time = time.time()
        used_time = end_time-start_time
        print("\nspeed=",StrOfSize(int(totle/used_time)),"/s (",StrOfSize(totle),"in",int(used_time*1000)/1000,"s )")
