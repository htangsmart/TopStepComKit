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
import time


def process_file_bar_cb(event, status, path, start_time, cur_size, total_size):
    if event == "onProcess":
        file_process_bar(float(cur_size) / total_size, start_str='=', total_length=15)
    elif event == "onSuccess":
        file_process_bar(1.0, start_str='=', total_length=15)
    elif event == "onComplete":
        used_time = time.time() - start_time
        if used_time == 0:
            used_time = 0.0001
        speed = "{}/s ({} in {}s)".format(StrOfSize(int(total_size / used_time)), StrOfSize(total_size),
                                          int(used_time * 1000) / 1000)
        print("\n{}\n".format(speed), end="")

    return False


def process_dir_bar_cb(event, path, start_time, cur_size, total_size):
    if event == "onProcess":
        process_bar(cur_size, total_size, path)
    elif event == "onSuccess":
        print('[{:0>4.1f}%] {}'.format(100, path), end="")
    elif event == "onComplete":
        print("")
    return False


def file_process_bar(percent, start_str='', total_length=0):
    bar = ''.join(["="] * int(percent * total_length)) + ''
    bar = start_str + bar.ljust(total_length) + ' |{:0>4.1f}%'.format(percent * 100)
    print(bar, end='\r', flush=True)


def process_bar(current, total, path):
    percent = current / float(total)
    print('[{:0>4.1f}%] {}'.format(percent * 100, path), end='\r', flush=True)


def StrOfSize(size):
    def strofsize(integer, remainder, level):
        if integer >= 1024:
            remainder = integer % 1024
            integer //= 1024
            level += 1
            return strofsize(integer, remainder, level)
        else:
            return integer, remainder, level

    units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB']
    integer, remainder, level = strofsize(size, 0, 0)
    if level + 1 > len(units):
        level = -1
    return '{}.{:>03d} {}'.format(integer, remainder, units[level])


# align_down(5, 4) = 4
def align_down(size, align):
    return size & ~(align - 1)


# align_up(5, 4) = 8
def align_up(size, align):
    return (size + (align - 1)) & ~(align - 1)


