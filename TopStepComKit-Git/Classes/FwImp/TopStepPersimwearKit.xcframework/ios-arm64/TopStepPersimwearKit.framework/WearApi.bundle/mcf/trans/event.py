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
import threading
import traceback

LOG_LVL = logging.INFO
LOG_TAG = 'mcf.event'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class DataEvent:
    def __init__(self):
        self.map = {}

    def notice(self, id, data):
        logger.debug("notice: %d", id)
        if str(id) in self.map:
            data_event = self.map[str(id)]
            if data_event["event"] is not None:
                data_event["data"] = data
                self.map[str(id)] = data_event
                data_event["event"].set()
        else:
            logger.error(str(id) + " event has not found")

    def create(self, id):
        event = threading.Event()
        self.map[str(id)] = {"event": event, "data": None}
        return event

    def wait(self, id, timeout=None):
        assert str(id) in self.map
        try:
            event = self.map[str(id)]['event']
        except Exception as e:
            logger.error(e)
        logger.debug("wait: %d", id)
        signaled = event.wait(timeout=timeout)
        if signaled and str(id) in self.map:
            return self.map[str(id)]["data"]
        else:
            logger.error(str(id) + " event wait timeout")

    def delete(self, id):
        if str(id) in self.map:
            del self.map[str(id)]

    def clear(self):
        try:
            for id in self.map:
                self.map[id]["event"].set()
            self.map = {}
        except Exception as e:
            logger.error(e)
            logger.error(traceback.format_exc())
