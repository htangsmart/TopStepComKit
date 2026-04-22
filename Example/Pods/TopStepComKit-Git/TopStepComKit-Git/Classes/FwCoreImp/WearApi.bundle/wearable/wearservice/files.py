from wearable.files.pull import pull
from wearable.files.push import push
import time
import os

def __generate_file_trans_callback(cb):

    def file_trans_empty_callback(event, status, path, start_time, cur_size, total_size):
        print(event, cur_size, total_size)
        if cb is not None:
            cb(event, cur_size, total_size)

    return file_trans_empty_callback

def wearservice_file_pull(local, remote, is_sync, callback):
    eventId = time.time() * 1000
    input = {}
    input["local"] = local
    input["remote"] = remote
    input['sync'] = is_sync
    input["_eventId"] = eventId
    input["_module"] = 'file_trans'

    cover_callback = __generate_file_trans_callback(callback)

    pull(local, remote, is_sync, input, cover_callback)

def wearservice_file_push(local, remote, is_sync, callback):
    eventId = time.time() * 1000
    input = {}
    input["local"] = local
    input["remote"] = remote
    input['sync'] = is_sync
    input["_eventId"] = eventId
    input["_module"] = 'file_trans'

    cover_callback = __generate_file_trans_callback(callback)

    push(local, remote, is_sync, input, cover_callback)