#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-12-16     tyustli      the first version
#

from urpc.src.ffi import *

LOG_LVL = logging.INFO
LOG_TAG = 'app_install'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class AppSvc:
    def __init__(self, rpc):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        logger.debug("app class init ok")

    def app_install(self, install_path):
        path = Arg(U8 | ARRAY, bytearray(install_path + '\0', encoding="utf8"))
        launch = Arg(U8, 1)
        ret = self.rpc.exec_ffi_func(self.daemon_id, "user_app_install", [path, launch], need_ack=False, need_rsp=True, timeout=60)
        if ret.value == 0:
            logger.debug("app install success")
            return 0
        else:
            logger.error("app install failed")
            return -1

    def app_launch(self, launch_path):
        path = Arg(U8 | ARRAY, bytearray(launch_path + '\0', encoding="utf8"))
        self.rpc.exec_ffi_func(self.daemon_id, "app_launch", [path], need_ack=False, need_rsp=True, timeout=30)
