# -*- coding: utf-8 -*-

import threading


class _Timer(threading.Thread):
    def __init__(self, interval, function, args=[], kwargs={}):
        threading.Thread.__init__(self)
        self.interval = interval
        self.function = function
        self.args = args
        self.kwargs = kwargs
        self.finished = threading.Event()

    def cancel(self):
        self.finished.set()

    def run(self):
        self.finished.wait(self.interval)
        if not self.finished.is_set():
            self.function(*self.args, **self.kwargs)
            self.finished.set()


class LoopTimer(_Timer):
    def __init__(self, interval, function, args=[], kwargs={}):
        _Timer.__init__(self, interval, function, args, kwargs)

    def run(self):
        while True:
            if not self.finished.is_set():
                self.finished.wait(self.interval)
                if threading.main_thread().is_alive():
                    self.function(*self.args, **self.kwargs)
                else:
                    self.finished.set()
                    break
            else:
                break
