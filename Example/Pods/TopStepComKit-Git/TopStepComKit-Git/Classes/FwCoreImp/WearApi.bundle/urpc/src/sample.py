#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-27     armink       the first version
#

import json

from urpc.src.ffi import *

LOG_LVL = logging.INFO
LOG_TAG = 'urpc.sample'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def print_test(input):
    logger.info("uRPC print test!")
    return bytearray()


def data_test(input):
    return bytearray("uRPC receive and response data!", encoding="utf8")


def speed(input):
    if len(input) == 0:
        return bytearray(1024)
    else:
        return bytearray()


def urpc_basic_sample(rpc):
    # 注册本地服务
    rpc.svc_register(rpc.Service("print_test", print_test))
    rpc.svc_register(rpc.Service("data_test", data_test))
    rpc.svc_register(rpc.Service("speed", speed))
    # 执行远端服务 print_test
    rpc.exec_svc(1, "print_test")
    # 执行远端服务 data_test
    input = bytearray("urpc send data!", encoding="utf8")
    output = rpc.exec_svc(1, "data_test", input, need_ack=True, need_rsp=True, timeout=1)
    logger.info(output.decode('utf-8'))
    # 执行远端服务 json_test
    input = {"arg1": 1, "arg2": "string", "arg3": True}
    input = bytearray(json.dumps(input), encoding="utf8")
    output = rpc.exec_svc(1, "json_test", input, need_ack=True, need_rsp=True, timeout=1)
    logger.info(output.decode('utf-8'))


def urpc_ffi_args_sample():
    u8 = Arg(U8, 0xAA)
    logger.info(u8.to_bytes().hex(' '))
    u16 = Arg(U16, 0x55AA)
    logger.info(u16.to_bytes().hex(' '))
    u32 = Arg(U32, 0x55AA55AA)
    logger.info(u32.to_bytes().hex(' '))

    u8_array = Arg(U8 | ARRAY, [0x11, 0x22, 0x33])
    logger.info(u8_array.to_bytes().hex(' '))
    u16_array = Arg(U16 | ARRAY, [0x1111, 0x2222, 0x3333])
    logger.info(u16_array.to_bytes().hex(' '))
    u32_array = Arg(U32 | ARRAY, [0x11111111, 0x22222222, 0x33333333])
    logger.info(u32_array.to_bytes().hex(' '))

    logger.info(hex(u8.from_bytes(u8.to_bytes())))
    logger.info(hex(u16.from_bytes(u16.to_bytes())))
    logger.info(hex(u32.from_bytes(u32.to_bytes())))
    logger.info([hex(x) for x in u8_array.from_bytes(u8_array.to_bytes())])
    logger.info([hex(x) for x in u16_array.from_bytes(u16_array.to_bytes())])
    logger.info([hex(x) for x in u32_array.from_bytes(u32_array.to_bytes())])


def urpc_ffi_svc_sample(rpc):
    a = Arg(U8, 0x45)
    b = Arg(U8, 0x54)
    # 执行远端 ffi 函数 u8_sum
    sum = rpc.exec_ffi_func(1, "u8_sum", [a, b], need_ack=False, need_rsp=True, timeout=1)
    logger.info("u8_sum(%s, %s)=%s", hex(a.value), hex(b.value), hex(sum.value))

    a = Arg(U32, 0x12345678)
    b = Arg(U32, 0x87654321)
    # 执行远端 ffi 函数 u32_sum
    sum = rpc.exec_ffi_func(1, "u32_sum", [a, b], need_ack=False, need_rsp=True, timeout=1)
    logger.info("u32_sum(%s, %s)=%s", hex(a.value), hex(b.value), hex(sum.value))

    offset = Arg(U32, 0x11111111)
    buffer = Arg(U8 | ARRAY, [0x11, 0x11, 0x11, 0x11, 0x11])
    buffer_len = Arg(U32, buffer.value_len)
    # 执行远端 ffi 函数 write_test
    result = rpc.exec_ffi_func(1, "write_test", [offset, buffer, buffer_len], need_ack=False, need_rsp=True, timeout=1)
    logger.info("write_test(%s, %s, %s)=%s", hex(offset.value), buffer.value, hex(buffer_len.value), hex(result.value))

    offset = Arg(U32, 0x00000001)
    buffer = Arg(U8 | ARRAY | EDITABLE, list(range(4)))
    buffer_len = Arg(U32, buffer.value_len)
    # 执行远端 ffi 函数 read_test
    result = rpc.exec_ffi_func(1, "read_test", [offset, buffer, buffer_len], need_ack=False, need_rsp=True, timeout=1)
    logger.info("read_test(%s, %s, %s)=%s", offset.value, buffer.value, buffer_len.value, result.value)
