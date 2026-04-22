#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-20     armink       the first version
#

import logging

LOG_LVL = logging.INFO
LOG_TAG = 'ffi'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

U8 = 0x01
U16 = 0x02
U32 = 0x04
ARRAY = 0x80
EDITABLE = 0x40


class Arg:
    def __init__(self, type=0, value=0):
        self.value = value
        self.type = type
        self.len = 1
        self.value_len = 0
        self.byteorder = 'little'
        if self.type & ARRAY == ARRAY:
            self.len += 2
            self.value_len += len(value) * (self.type & 0x0F)
        else:
            self.value_len += self.type & 0x0F

        if self.type & EDITABLE != EDITABLE:
            self.len += self.value_len

    def to_bytes(self, byteorder='little'):
        self.byteorder = byteorder
        type_bytes = self.type & 0x0F
        result = bytearray()
        result.append(self.type)

        if self.type & ARRAY == ARRAY:
            assert (self.value_len < 65536)
            result += self.value_len.to_bytes(2, byteorder=byteorder)
            if self.type & EDITABLE != EDITABLE:
                for i in range(int(self.value_len / type_bytes)):
                    result += self.value[i].to_bytes(type_bytes, byteorder=byteorder)
        else:
            if self.type & EDITABLE != EDITABLE:
                result += self.value.to_bytes(type_bytes, byteorder=byteorder)

        return result

    def from_bytes(self, raw, byteorder='little'):
        self.type = raw[0]
        self.len = 1
        self.value = 0
        self.byteorder = byteorder
        type_bytes = self.type & 0x0F
        if self.type & ARRAY == ARRAY:
            arg_hdr = 1 + 2
            value_len = int((len(raw) - arg_hdr) / type_bytes)
            assert (value_len < 65536)
            raw = raw[arg_hdr:]
            self.value = []
            for i in range(int(value_len / type_bytes)):
                value = int.from_bytes(raw[i * type_bytes: (i + 1) * type_bytes], byteorder)
                self.value.append(value)
                self.value_len += type_bytes
                self.len += type_bytes
        else:
            arg_hdr = 1
            raw = raw[arg_hdr: arg_hdr + type_bytes]
            self.value = int.from_bytes(raw, byteorder)
            self.value_len = type_bytes

        self.len += self.value_len

        return self.value

    def signed(self):
        if self.type & ARRAY == ARRAY:
            values = []
            for value in self.value:
                values.append(int.from_bytes(value.to_bytes(self.value_len, self.byteorder), self.byteorder, signed=True))
            return values
        else:
            return int.from_bytes(self.value.to_bytes(self.value_len, self.byteorder), self.byteorder, signed=True)
