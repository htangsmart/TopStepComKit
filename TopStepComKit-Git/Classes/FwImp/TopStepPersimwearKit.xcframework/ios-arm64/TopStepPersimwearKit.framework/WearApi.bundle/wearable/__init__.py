#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-10-15     armink       the first version
#

BLE_GATT_MTU_SIZE = 517
BLE_GATT_DATA_FRAME_SIZE = BLE_GATT_MTU_SIZE - 3 - 2 # 不 -2 可能会有传输异常问题，待确认
UDBD_SERVER_VER_NUM = 0x10400
