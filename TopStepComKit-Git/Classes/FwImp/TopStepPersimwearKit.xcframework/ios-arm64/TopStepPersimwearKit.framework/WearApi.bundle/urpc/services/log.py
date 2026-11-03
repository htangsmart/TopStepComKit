#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-26     BalanceTWK   the first version
#

from urpc.src.ffi import *
import logging

LOG_LVL = logging.INFO
LOG_TAG = 'svc.log'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class LogSvc:
    def __init__(self, rpc, console_outout):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        self.rpc.svc_register(rpc.Service("putlog", console_outout))

    def logcat_register(self, dst_id):

        dst_id = Arg(U8, dst_id)

        result = self.rpc.exec_ffi_func(self.daemon_id, "udbd_log_register", [dst_id], need_ack=False, need_rsp=True, timeout=1)

        return result

    def logcat_unregister(self):

        result = self.rpc.exec_ffi_func(self.daemon_id, "udbd_log_unregister", need_ack=False, need_rsp=True,
                                        timeout=1)

        return result
