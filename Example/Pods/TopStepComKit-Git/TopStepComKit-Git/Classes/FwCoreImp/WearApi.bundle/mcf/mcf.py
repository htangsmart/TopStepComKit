#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-13     armink       the first version
#

import logging
from enum import Enum

LOG_LVL = logging.INFO
LOG_TAG = 'mcf'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

# configuration
MCF_PKT_MAX_SIZE = 1024 * 1024
MCF_ACK_TIMOUT = 0.5 #单位 S
MCF_REQ_RERTY_TIMES = 2
MCF_ACK_RERTY_TIMES = 2


class MCF:

    def __init__(self):
        self.is_executing = False


class ProtoType(Enum):
    D2D = 1
    ARP = 2
    USER = 3
