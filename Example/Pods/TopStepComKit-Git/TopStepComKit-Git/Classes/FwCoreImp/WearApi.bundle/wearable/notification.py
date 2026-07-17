# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-05-14     armink       the first version
#

import global_var
from urpc.src.ffi import *
from wearable import json_lpc


def service_notification_push(input):
    rpc = global_var.get('rpc')
    title = Arg(U8 | ARRAY, bytearray(input['title'] + '\0', encoding="utf8"))
    icon_path = Arg(U8 | ARRAY, bytearray(input['icon_path'] + '\0', encoding="utf8"))
    sender = Arg(U8 | ARRAY, bytearray(input['sender'] + '\0', encoding="utf8"))
    text_content = Arg(U8 | ARRAY, bytearray(input['text_content'] + '\0', encoding="utf8"))
    image_context_path = Arg(U8 | ARRAY, bytearray(input['image_context_path'] + '\0', encoding="utf8"))
    msg_type = Arg(U8 | ARRAY, bytearray(input['msg_type'] + '\0', encoding="utf8"))
    presenting_ways = Arg(U8 | ARRAY, bytearray(input['presenting_ways'] + '\0', encoding="utf8"))
    priority = Arg(U32, 1)
    timestamp = Arg(U32, input['timestamp'])
    # 执行远端 ffi 函数
    result = rpc.exec_ffi_func(1, "svc_notification_push",
                               [title, icon_path, sender, text_content, image_context_path, msg_type, presenting_ways,
                                priority, timestamp], need_ack=False, need_rsp=True, timeout=10)
    return json_lpc.gen_success_output_json()
