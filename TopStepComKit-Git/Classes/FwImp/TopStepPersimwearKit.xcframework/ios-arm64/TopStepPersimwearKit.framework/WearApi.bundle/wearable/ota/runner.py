# -*- coding: utf-8 -*-
from wearable.ota import upgrade
import threading
import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.runner'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

# 全局 runner 列表以及使用锁
__runner_list__ = []
__runner_lock__ = None


class Runner(object):

    def __init__(self, step, resource):
        super().__init__()
        self.__quit_step_list__ = []

        # 构造step对象
        self.__step__ = upgrade.Upgrade(step, resource.config())
        # 构造quit step对象
        if 'quit' in step:
            for quit_item in step['quit']:
                quit_step = upgrade.Upgrade(quit_item, resource.config())
                self.__quit_step_list__.insert(0, quit_step)

    def step(self):
        return self.__step__

    def init(self):
        self.__step__.init()
        if len(self.__quit_step_list__) > 0:
            for quit_step in self.__quit_step_list__:
                quit_step.init()

    def run(self):
        self.__step__.run()

    def progress(self):
        return self.__step__.progress()

    def due_time(self):
        return self.__step__.due_time()

    def quit(self):
        self.__step__.quit()

    def quit_run(self):
        if len(self.__quit_step_list__) > 0:
            for quit_step in self.__quit_step_list__:
                quit_step.run()


def runner_list_create(resource):
    if globals()['__runner_lock__'] is None:
        globals()['__runner_lock__'] = threading.Lock()
    # 全局变量加锁
    globals()['__runner_lock__'].acquire()
    # 首先清空当前列表中的对象
    globals()['__runner_list__'].clear()
    # 依据resource中的steps对象创建runner
    for step in resource.steps():
        runner = Runner(step, resource)
        globals()['__runner_list__'].append(runner)
    # 全局变量解锁
    globals()['__runner_lock__'].release()
    # 全局 runner 列表
    return globals()['__runner_list__']


def runner_list_obtain():
    # 获取全局 runner 列表
    return globals()['__runner_list__']
