#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-13     armink       the first version
#
import logging
import threading
import traceback
from queue import Queue

from .d2d import D2DProto
from .packet import TransPacket

from mcf.link.link import MCFLinkStatus

LOG_LVL = logging.INFO
LOG_TAG = 'mcf.trans'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class MCFTransLayer:

    def __init__(self, linklayer, did):
        self.linklayer = linklayer
        # TODO 封包拆包机制
        # TODO 传输自动终止功能：对于具备 ACK 可以感知链路层的连接与断开动作，已建立的连接，向上抛出异常；对于不具备 ACK 的链路层设备，传输层需要提供心跳检测机制
        self.d2d = D2DProto(self, did)
        self.send_queue = Queue()
        self.send_thread = threading.Thread(target=self.__send_entry, daemon=True, name="trans_send")
        self.send_thread.start()
        self.recv_thread = threading.Thread(target=self.__recv_entry, daemon=True, name="trans_recv")
        self.recv_thread.start()
        self.support_ack = False
        logger.debug("MCF Transport layer initialize success")

    def get_proto(self, type):
        # TODO 后续支持其他协议
        return self.d2d

    # 发送传输层数据（默认同步模式，也支持异步模式）
    def send(self, pkt, timeout=None, non_block=False):
        if non_block:
            self.send_queue.put(pkt)
        else:
            self.linklayer.send(pkt, timeout)

    def __send_entry(self):
        while True:
            link_layer_status = MCFLinkStatus().get_link_status()

            if not link_layer_status:
                self.d2d.pkt_events.clear()
                self.send_queue = Queue()

            pkt = self.send_queue.get()
            self.send(pkt)

    def __recv_entry(self):
        try:
            logger.debug("MCF transport layer dispatcher is running")
            while True:
                # 接收链路层的所有数据
                link_pkt = self.linklayer.recv()
                if len(link_pkt) == 0:
                    continue
                # 解包为传输层报文
                trans_pkt = TransPacket()
                trans_pkt.unpack(link_pkt)
                if len(trans_pkt.payload):
                    # TODO 目前仅处理了 D2D 格式的报文
                    if trans_pkt.proto == trans_pkt.Type.D2D:
                        self.d2d.parser(trans_pkt.payload)
                    else:
                        assert 0
        except Exception as e:
            logger.error(traceback.format_exc())
