# -*- coding: utf-8 -*-

import time
from wearable.ota.looptimer import LoopTimer

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.upgrade.progress'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

class Progress(object):
    """
    进度管理类，用于计算进度及剩余时间等信息
    :param __name__: 进度名字
    :param __state__: 状态, ('Init', 'Process', 'Success', 'Failed')
    :param __average_efficiency__: 平均效率
    :param __start_time__: 启动时间戳
    :param __uses_time__: 使用时间，单位毫秒
    :param __remain_time__: 剩余时间，单位毫秒
    :param __total__: 总量
    :param __complete__: 完成量
    :param __notify__: 状态修改通知函数
    """

    # 进度状态
    Init = 0,
    Process = 1,
    Success = 2,
    Failed = -1,
    StateSet = (Init, Process, Success, Failed),
    RuningSet = (Process),
    CompleteSet = (Success, Failed)
    StateName = {Init: 'onInit', Process: 'onProcess', Success: 'onSuccess', Failed: 'onFailed'}

    def __reset(self):
        # 初始化对象成员
        self.__state__ = self.Init
        self.__average_efficiency__ = [
            {"weight": 0.1, "Efficiency": self.Efficiency(5)},
        ]
        self.__start_time__ = 0
        self.__uses_time__ = 0
        self.__remain_time__ = 0
        self.__complete__ = 0

    class Efficiency(object):
        """
        效率类，用于统计单位时间内的增量
        :param __cycle__: 周期
        :param __container__: 容器，保存数据
        :param __efficiency__: 效率值，单位时间内的增量
        :param __last_time__: 上一次时间戳
        """

        def __init__(self, cycle):
            """
            类初始化函数
            :param cycle: 统计周期，多少次计算一次数据，特殊值0: 始终计算
                例如: cycle 为 3，第 1，2 包不计算，第 3 包计算，第 4 包数据进来，会扔掉第一包数据，计算最后三包数据
            """
            super().__init__()

            self.__cycle__ = int(cycle)
            self.__container__ = []
            self.__efficiency__ = 0
            self.__last_time__ = int(round(time.time() * 1000))
            self.__start_time__ = int(round(time.time() * 1000))
            self.__total__ = 0.0

        def update(self, variation):
            """
            更新一次数据
            """
            self.__total__ = self.__total__ + variation
            # 计算数据
            current_time = int(round(time.time() * 1000))

            # 删除旧数据
            if self.__cycle__ > 0:
                while len(self.__container__) >= self.__cycle__:
                    self.__container__.pop(0)
                # 添加新数据
                t = current_time - self.__last_time__
                if t <= 0:
                    t = 1
                self.__container__.append(variation / t)
            else:
                t = current_time - self.__start_time__
                if t <= 0:
                    t = 1
                self.__container__.append(self.__total__ / t)
            # 计算平均数据
            average = 0.0
            count = 0
            for i in self.__container__:
                average = average + i
                count = count + 1
            average = average / count
            self.__efficiency__ = average
            # 更新时间
            self.__last_time__ = int(round(time.time() * 1000))
            return self.__efficiency__

        def efficiency(self):
            """
            获取效率
            """
            return self.__efficiency__

        def reset_time(self):
            """
            更新上次时间戳
            """
            t = int(round(time.time() * 1000))
            self.__last_time__ = t
            self.__start_time__ = t

        def last_time(self):
            """
            返回上一次时间戳
            """
            return self.__last_time__

    def __update(self, msgs, variation=0.0):
        """
        更新时间，性能及剩余时间
        :param variation: 增加的百分比量 
        """
        # 更新
        current_time = int(round(time.time() * 1000))
        self.__uses_time__ = current_time - self.__start_time__
        average = 0.0
        if variation > 0:
            weight_total = 0
            for i in self.__average_efficiency__:
                weight_total = weight_total + i["weight"]
            # 根据权重计算平均效率
            for i in self.__average_efficiency__:
                average = average + i["Efficiency"].update(variation) * (i["weight"] / weight_total)
        # 计算剩余时间
        if average > 0:
            self.__remain_time__ = (1 - self.percentage()) / average
        # 执行通知
        self.__notify(msgs)

    def __init__(self, name, total):
        """
        进度类构造函数
        """
        super().__init__()
        self.__name__ = str(name)
        self.__total__ = int(total)
        self.__notify__ = []
        self.__reset()
        self.__error__ = ''

    def reset(self):
        """
        进度状态及数值重置
        """
        # 初始化对象成员
        self.__reset()

    def set_start(self, msgs=None):
        """
        设置开始状态
        """
        # 修改状态
        if self.__state__ == self.Init:
            self.__start_time__ = int(round(time.time() * 1000))
        # 设置毫秒级时间戳
        self.__state__ = self.Process
        for i in self.__average_efficiency__:
            i["Efficiency"].reset_time()
        self.__update(msgs)

    def set_fail(self, msgs=None):
        """
        设置失败状态
        """
        self.__state__ = self.Failed
        self.__update(msgs)

    def set_success(self, msgs=None):
        """
        设置成功状态
        """
        self.__state__ = self.Success
        self.__update(msgs)

    def is_start(self):
        """
        查询是否开始
        """
        return self.__state__ in self.RuningSet

    def is_complete(self):
        """
        查询是否完成
        """
        return self.__state__ in self.CompleteSet

    def is_failed(self):
        """
        查询是否失败
        """
        return self.__state__ == self.Failed

    def is_success(self):
        """
        查询是否成功
        """
        return self.__state__ == self.Success

    def increase(self, n, msgs=None):
        """
        设置增加量
        """
        self.__complete__ = self.__complete__ + int(n)
        self.__update(msgs, int(n) / self.__total__)

    def set(self, n, msgs=None):
        """
        设置完成量
        """
        tmp = n - self.__complete__
        self.__complete__ = n
        self.__update(msgs, tmp / self.__total__)

    def get(self):
        """
        获取完成量
        """
        return self.__complete__

    def total(self):
        """
        获取总量
        """
        return self.__total__

    def set_total(self, total, msgs=None):
        """
        修改总量
        """
        if self.__total__ > 0:
            t = self.__complete__ * (int(total) - self.__total__) / (int(total) * self.__total__)
        else:
            t = 0
        self.__total__ = int(total)
        self.__update(msgs, t)

    def percentage(self):
        """
        获取百分比
        """
        if self.is_success():
            # 已经成功，强制返回 1
            return 1
        else:
            if self.__total__ <= 0:
                return 0
            _tmp = self.__complete__ / self.__total__
            if _tmp > 0.9998:
                # 未成功的情况下，进度值上限未 0.9998
                _tmp = 0.9998
            return _tmp

    class Notify(object):
        """
        进度通知对象
        :param callback: 通知回调
        :param args: 回调函数参数
        """

        def __init__(self, callback, args):
            super().__init__()

            self.callback = callback
            self.args = args

        def call(self, msgs):
            func = self.callback
            args = self.args
            args_len = len(args)
            if args_len == 0:
                return func(msgs)
            elif args_len == 1:
                return func(msgs, args[0])
            elif args_len == 2:
                return func(msgs, args[0], args[1])
            elif args_len == 3:
                return func(msgs, args[0], args[1], args[2])
            elif args_len == 4:
                return func(msgs, args[0], args[1], args[2], args[3])
            elif args_len == 5:
                return func(msgs, args[0], args[1], args[2], args[3], args[4])
            elif args_len == 6:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5])
            elif args_len == 7:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5], args[6])
            elif args_len == 8:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
            elif args_len == 9:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
            elif args_len == 10:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
                            args[9])
            elif args_len == 11:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
                            args[9], args[10])
            elif args_len == 12:
                return func(msgs, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8],
                            args[9], args[10], args[11])
            else:
                raise RuntimeError('Too many function arguments')

    def set_notify(self, callback, *args):
        """
        设置状态更新通知函数
        """
        n = self.Notify(callback, args)
        self.__notify__.append(n)
        return n

    def __notify(self, msgs):
        """
        执行通知函数(内部函数)
        """
        # 进度开始后，才执行通知函数
        if self.__state__ == self.Init:
            return
        # 更新时间
        self.__uses_time__ = int(round(time.time() * 1000))
        # 当前进度信息
        self.__error__ = msgs
        # 执行所有的通知
        for n in self.__notify__:
            n.call(msgs)

    def cancel_notify(self, notify):
        """
        取消通知函数
        """
        if notify in self.__notify__:
            self.__notify__.remove(notify)

    def get_name(self):
        """
        获取进度名字
        """
        return self.__name__

    def details(self):
        """
        获取当前升级进度的详细信息
        """
        # 更新时间
        self.__uses_time__ = int(round(time.time() * 1000)) - self.__start_time__
        return {
            "name": self.__name__,
            "state": self.StateName[self.__state__],
            "start_time": self.__start_time__,
            "uses_time": self.__uses_time__,
            "remain_time": self.__remain_time__,
            "total": self.__total__,
            "complete": self.__complete__,
            "percentage": self.percentage()
        }

    def uses_time(self):
        """
        获取使用时间
        :return:
        """
        return self.__uses_time__

    def remain_time(self):
        """
        获取剩余时间
        :return:
        """
        return self.__remain_time__

    def error(self):
        return self.__error__

class ProgressVC(Progress):
    ProgressIndex = 0
    ProportionIndex = 1
    NotifyIndex = 2
    """
    进度容器类，用于管理一组 Progress 类
    :param: __container__: 进度容器
    """

    def __init__(self, name):
        # 初始化父类
        super().__init__(name, 0)
        self.__container__ = []
        self.__uuid__ = str(time.time() * 1000)

    def has(self, progress):
        """
        查找是否存在 progress 对象
        """
        for i in self.__container__:
            if progress == i[self.ProgressIndex]:
                return True
        return False

    def append(self, progress, proportion):
        """
        添加进度成员
        :param: progress 进度类
        :param: proportion 进度占比
        """

        def __percentage_update(msgs):
            """
            更新容器进度
            """
            _self = self
            complete = 0
            _success = True
            _failed = False
            # 遍历整个列表，更新当前进度
            for i in _self.__container__:
                _progress = i[_self.ProgressIndex]
                _proportion = i[_self.ProportionIndex]
                if _progress.is_start():
                    if _self.is_start() == False:
                        _self.set_start(msgs)
                    _success = False
                    # 根据占比计算总进度
                    complete = complete + _progress.percentage() * _proportion
                elif _progress.is_success():
                    # 统计是否全部成功
                    complete = complete + _proportion
                    _success = _success and True
                elif _progress.is_failed():
                    complete = complete + _progress.percentage() * _proportion
                    # 统计是否全部失败
                    _failed = _failed or True
                else:
                    # 该进度未开始
                    _success = False
            # 设置当前值
            _self.set(complete, msgs)
            if _failed:
                # 检查是否失败
                _self.set_fail(msgs)
            elif _success:
                # 检查是否成功
                _self.set_success(msgs)

        if self.has(progress) == False:
            # 更改总量
            super().set_total(super().total() + proportion)
            # 设置通知
            notify = progress.set_notify(__percentage_update)
            self.__container__.append((progress, int(proportion), notify))

    def remove(self, progress):
        """
        从容器中删除进度成员
        """
        for i in self.__container__:
            if progress == i[self.ProgressIndex]:
                # 更改总量
                super().set_total(super().total() - i[self.ProportionIndex])
                # 移除通知
                progress.cancel_notify(i[self.NotifyIndex])
                # 从列表中移除
                self.__container__.remove(i)

    def reset(self):
        """
        重写容器类重置函数
        :return:
        """
        # 重置容器内所有进度
        for i in self.__container__:
            i[self.ProgressIndex].reset()
        # 重置自身
        super().reset()


    def debug(self):
        """
        重写容器类调试函数
        :return:
        """
        # 输出容器类中所有的信息
        for i in self.__container__:
            logger.info("[self.ProgressIndex] = %s " %(i[self.ProgressIndex].details()));

class ProgressPseudo(Progress):
    """
    伪进度类，每秒自动增长
    :param __time__: 定时器对象
    """

    def __init__(self, name, total_time):
        """
        类初始化函数
        :param name: 进度名称
        :param time: 预期时间(秒)
        """
        # 初始化父类
        super().__init__(name, int(total_time))
        self.__time__ = None

    def time_start(self):
        """
        启动定时器
        """
        def __timeout_handle(p):
            """
            定时器超时处理函数
            """
            p.increase(1)
            if p.get() == p.total():
                p.time_stop()

        if self.__time__ is not None:
            self.__time__.cancel()
            self.__time__ = LoopTimer(1, __timeout_handle, args=(self,))
        else:
            self.__time__ = LoopTimer(1, __timeout_handle, args=(self,))
        self.__time__.start()

    def time_stop(self):
        """
        停止定时器
        """
        if self.__time__ is not None:
            self.__time__.cancel()
            self.__time__ = None

    def reset(self):
        """
        重置复位
        """
        # 取消定时器
        self.time_stop()
        # 重置父类
        super().reset()

    def set_start(self):
        """
        设置开始状态
        """
        super().set_start()
        # 启动定时器
        self.time_start()

    def set_fail(self):
        """
        设置失败状态
        """
        # 取消定时器
        self.time_stop()
        # 设置失败
        super().set_fail()

    def set_success(self):
        # 取消定时器
        self.time_stop()
        # 设置成功
        super().set_success()
