# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-05-18     armink       the first version
#
import traceback
import threading
import global_var

from urpc.src.ffi import *
from wearable import json_lpc
from wearable.files.pull import pull
from wearable.tsdb_to_sqlite3.tsdb_to_sqlite3 import trans_to_sqlite

LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.system_data'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

def tsdb_pull_cb(event, status, path, start_time, cur_size, total_size):
    pass

def service_system_data_sync(input):
    try:
        # 获取全局锁
        lock = global_var.get('system_data_sync_lock')
        if lock is None:
            lock = threading.Lock()
            global_var.set('system_data_sync_lock', lock)
        # 加锁
        lock.acquire()
        # 文件同步
        pulls = input['pull']
        for key in pulls:
            # 使用一个空函数，同步 tsdb 的进度不需要传递到文件传输回调中
            pull(key, pulls[key], True, input, callback=tsdb_pull_cb)
        # 数据库转换
        logger.info("------------------ trans_to_sqlite -> start ------------------")
        tsdbs = input['tsdb']
        for key in tsdbs:
            logger.info("tsdb   path : %s", key)
            logger.info("sqlite path : %s", tsdbs[key])
            path_arr = tsdbs[key].split('@')
            if len(path_arr) > 1:
                table_name = path_arr[len(path_arr) - 1]
            else:
                table_name = 'tsdb'
            trans_to_sqlite(key, path_arr[0], table_name)
            logger.info("---------------------------------------------------------------")
        logger.info("------------------ trans_to_sqlite -> finish ------------------")
        # 释放锁
        lock.release()
        return json_lpc.gen_success_output_json()
    except Exception as e:
        logger.error(traceback.format_exc())
        # 释放锁
        lock.release()
        return json_lpc.gen_failed_output_json(e)

