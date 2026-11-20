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

import os
import logging
import threading
import time
import serial

from .link import *
from ..mcf import MCF_PKT_MAX_SIZE

LOG_LVL = logging.INFO
LOG_TAG = 'mcf.link.uart'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class MCFLinkDeviceUart(MCFLinkLayer.Device):
    def __init__(self, link_layer, pid, port, baudrate, bytesize, stopbits, parity, crc16):
        try:
            self.uart = serial.Serial(port, baudrate, bytesize=bytesize, stopbits=stopbits, parity=parity)
        except Exception as e:
            raise e

        self.port = port
        self.link_layer = link_layer
        self.need_crc16 = crc16
        self.recv_lock = threading.Lock()
        self.send_lock = threading.Lock()
        # 初始化设备
        self.device = super().__init__(pid=pid, link_type=self.LinkType.UART, ack=False,
                                       mtu=MCF_PKT_MAX_SIZE,
                                       send=self.__uart_send, recv=self.__uart_recv)
        # 注册设备到链路层
        link_layer.device_register(self.device)
        logger.debug("MCF UART link device (%s) register success", port)

        self.link_device = LinkDevice(self.mtu, self.recv_frames, self.link_layer, self.recv_lock)
        # 启动线程并开始接收串口数据
        self.recv_thread = threading.Thread(target=self.__recv_entry, daemon=True, name="uart{}_recv".format(str(port)))
        self.recv_thread.start()

    def __recv_entry(self):
        header_ok = False
        recv_buf = bytes()
        logger.debug("%s recv thread is running", self.uart.name)
        while True:
            try:
                if header_ok is False and len(recv_buf) > MCF_FRAME_READ_LEN_LEN:
                    data = bytes()
                else:
                    data = self.uart.read(self.uart.inWaiting() or 1)
            except Exception as e:
                logger.debug("uart: {} closed".format(self.uart.name))
                # 线程结束
                self.uart.close()
                del self.link_layer.devices[0].daemon_devices[self.device.pid]
                self.link_layer.devices_destroy(self.device)
                break

            logging.debug("data: {}".format(data))
            recv_buf, header_ok = self.link_device.receive(data, recv_buf, header_ok,
                                                         "uart " + str(self.port))

    def __uart_recv(self):
        return self.link_device.transfer_recv(need_crc16=self.need_crc16)

    def __uart_send(self, pkt, timeout=None):
        self.send_lock.acquire()
        frame = self.link_device.pkt_to_frame(pkt, need_crc16=self.need_crc16)
        self.uart.write(frame)
        self.send_lock.release()
        logger.debug(self.uart.name + " send a frame, len: " + str(len(frame)) + ", data: " + str(frame))
