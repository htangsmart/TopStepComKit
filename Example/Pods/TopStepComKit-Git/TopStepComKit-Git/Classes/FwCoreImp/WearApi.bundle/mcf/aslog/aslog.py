#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-22     armink       the first version
#
import sys
import threading


class AsyncStream:
    def __init__(self, stream=None):
        self._name = "async"
        self.sem = threading.Semaphore(0)
        self.logs = []
        self.async_output_thread = threading.Thread(target=self.__async_output, daemon=True)
        self.async_output_thread.start()

    def __async_output(self):
        while True:
            try:
                self.sem.acquire()
                log = self.logs.pop(0)
                sys.stderr.write(log)
            except Exception as e:
                sys.stderr.write(str(e))

    def flush(self):
        pass

    def write(self, record):
        self.logs.append(record)
        self.sem.release()

