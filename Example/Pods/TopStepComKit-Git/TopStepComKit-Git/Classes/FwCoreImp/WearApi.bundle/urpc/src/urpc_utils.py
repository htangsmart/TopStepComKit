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
LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.jsonsvc'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

class UrpcError(Exception):
    """Base class for uRPC related exceptions."""
    def __init__(self):
        super().__init__()


class UrpcTimeoutException(UrpcError):
    """Service execute timeout exception"""
    def __init__(self):
        super().__init__()
        logger.debug("timeout")
    def __str__(self):
        return 'Timeout'

class UrpcDisconnectException(UrpcError):
    def __str__(self):
        return "Disconnect"


class UrpcSvcNotFoundException(UrpcError):
    """Service not found exception"""
    def __init__(self):
        logger.debug("svc not found")
    def __str__(self):
        return 'svc not found'
