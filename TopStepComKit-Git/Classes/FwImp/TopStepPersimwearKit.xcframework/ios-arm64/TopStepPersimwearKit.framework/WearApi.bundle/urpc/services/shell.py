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
import sys
import time
import logging

from urpc.src.ffi import *

LOG_LVL = logging.INFO
LOG_TAG = 'svc.shell'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class ShellSvc:
    def __init__(self, rpc, console_outout):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        self.rpc.svc_register(rpc.Service("cout", console_outout))

    def shell_start(self):
        shell_buff = bytearray()
        self.rpc.exec_svc(self.daemon_id, "urpc_shell_start", shell_buff, need_ack=False, need_rsp=True, timeout=1)
        logger.debug("shell_start ok")

    def shell_end(self):

        shell_buff = bytearray()
        self.rpc.exec_svc(self.daemon_id, "urpc_shell_end", shell_buff, need_ack=False, need_rsp=True, timeout=1)
        logger.debug("shell_end ok")

    def shell_puts(self, shell_buff):
        self.rpc.exec_svc(self.daemon_id, "cin", shell_buff, need_ack=False, need_rsp=False, timeout=1)
        logger.debug("shell_write ok")

    def shell_write(self, buf):
        shell_buff = bytearray(buf, encoding="utf8")
        self.shell_puts(shell_buff)

    def shell_write_test(self, buf):
        shell_buff = bytearray(buf, encoding="utf8")
        self.rpc.exec_svc(self.daemon_id, "urpc_shell_input_test", shell_buff, need_ack=False, need_rsp=False, timeout=1)
        logger.debug("shell_write ok")

    def shell_exec(self, cmd):
        buffer = Arg(U8 | ARRAY, bytearray(cmd + '\0', encoding="utf8"))
        buffer_len = Arg(U32, len(cmd))
        self.rpc.exec_ffi_func(self.daemon_id, "msh_exec", [buffer, buffer_len], need_ack=True, need_rsp=False)


def device_output(inputs):
    sys.stdout.write(inputs.decode('utf-8'))
    return inputs


def shell_test(rpc):
    shell = ShellSvc(rpc, device_output)
    ShellSvc.shell_start(shell)
    ShellSvc.shell_write(shell, "ps\n")
    time.sleep(1)
    ShellSvc.shell_end(shell)
