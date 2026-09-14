#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2021, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-06-05     liukang      the first version
#

import os
import socket
import logging
import threading

from .link import MCFLinkLayer
from .link import LinkDevice
from ..mcf import MCF_PKT_MAX_SIZE


LOG_LVL = logging.INFO
LOG_TAG = 'mcf.link.socket'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


MCF_SOCKET_FRAME_READ_LEN_LEN = 3
MCF_SOCKET_FRAME_HEAD_LEN = 5  # 5 bytes frame header
MCF_SOCKET_FRAME_TAIL_LEN = 1  # 1 bytes frame tail
MCF_SOCKET_FRAME_HEAD = bytes.fromhex('FC')
MCF_SOCKET_FRAME_END_SIGN = bytes.fromhex('CF')
MCF_SOCKET_FRAME_MIN_LEN = MCF_SOCKET_FRAME_HEAD_LEN + MCF_SOCKET_FRAME_TAIL_LEN

"""
保存 socket 连接对象
"""
class MCFLinkDeviceSocket(MCFLinkLayer.Device):
    def __init__(self, link_layer, client, port, port_id):
        self.client = client
        self.socket_port = port
        logger.debug("socket port: {}".format(self.socket_port))
        self.link_layer = link_layer
        # 收发锁
        self.recv_lock = threading.Lock()
        self.send_lock = threading.Lock()
        # 初始化设备
        device = super().__init__(port_id, self.LinkType.SOCKET, False, MCF_PKT_MAX_SIZE,
                                  self.__socket_send, self.__socket_recv)


        # 将设备注册到链路层
        link_layer.device_register(device)
        self.device = device
        logger.debug("MCF SOCKET link device ({0}) register success".format(port_id))

        self.socket_link = LinkDevice(self.mtu, self.recv_frames, self.link_layer, self.recv_lock)

        # 启动线程并开始接收数据，client 接收 server 发送的数据
        self.recv_thread = threading.Thread(target=self.__recv_entry, daemon=True,
                                            name="socket{}_recv".format(self.socket_port))
        self.recv_thread.start()

    def __recv_entry(self):
        header_ok = False
        recv_buf = bytes()

        while True:
            try:
                receiver_bsize = self.client.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)
                data = self.client.recv(receiver_bsize)
                logger.debug("char.input %d, data: %s", len(bytes(data)), bytes(data).hex(' '))
                if len(data) == 0:
                    logger.debug("socket link: {} exception".format(self.socket_port))
                    self.client.close()
                    self.link_layer.devices_destroy(self.device)
                    break
            except Exception as e:
                logger.warning("socket: {} closed".format(self.socket_port))
                # 关闭 socket
                self.client.close()
                # destroy socket deice
                self.link_layer.devices_destroy(self.device)
                break

            recv_buf, header_ok = self.socket_link.receive(data, recv_buf, header_ok, "socket " + str(self.socket_port))

    def __socket_recv(self):
        return self.socket_link.transfer_recv()

    # client 通过 socket 将消息发送到 server，由 server 进行转发到 Daemon
    def __socket_send(self, pkt, timeout=None):

        frame = self.socket_link.pkt_to_frame(pkt)

        self.send_lock.acquire()
        self.client.sendall(frame)
        logger.debug("socket port: {} send a frame, len: {}, data: {}".format(self.socket_port, str(len(frame)), str(frame)))
        self.send_lock.release()
