#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-19     armink       the first version
#
from enum import Enum

from ..mcf import ProtoType


class TransPacket:
    class Type(Enum):
        D2D = ProtoType.D2D.value
        ARP = ProtoType.ARP.value
        USER = ProtoType.USER.value

    def __init__(self, proto=Type.D2D, payload=None):
        self.proto = proto
        self.payload = payload

    def pack(self):
        raw_pkt = bytearray()
        raw_pkt.append(self.proto.value)
        raw_pkt += self.payload
        return raw_pkt

    def unpack(self, raw_pkt):
        self.proto = self.Type(raw_pkt[0])
        self.payload = raw_pkt[1:]
        return len(self.payload)
