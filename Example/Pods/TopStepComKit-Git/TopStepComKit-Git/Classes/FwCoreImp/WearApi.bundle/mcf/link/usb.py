#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2021, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-02-18     liukang      the first version
#

import sys
import struct
import usb.core
import usb.util
import logging
import threading

from .link import *
from ..mcf import MCF_PKT_MAX_SIZE


LOG_LVL = logging.INFO
LOG_TAG = 'mcf.link.usb'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

MCF_USB_MSG_SEND = 0x00


class MCFLinkDeviceUsb(MCFLinkLayer.Device):
    def __init__(self, link_layer, pid, serial, device, interface):
        self.usb = device
        self.interface = interface
        self.inter_number = interface.bInterfaceNumber
        self.endpoint_in = 0
        self.endpoint_out = 0
        self.usb.set_configuration()
        self.find_endpoint()

        self.link_layer = link_layer
        self.recv_lock = threading.Lock()
        self.send_lock = threading.Lock()
        # 初始化设备
        device = super().__init__(pid, self.LinkType.USB, True, MCF_PKT_MAX_SIZE,
                                  self.__usb_send, self.__usb_recv)
        # 注册设备到链路层
        link_layer.device_register(device)
        self.device = device
        self.serial = serial
        logger.debug("MCF USB link device ({0}) register success".format(serial))

        self.usb_link = LinkDevice(self.mtu, self.recv_frames, self.link_layer, self.recv_lock)

        # 启动线程并开始接收数据
        self.recv_thread = threading.Thread(target=self.__recv_entry, daemon=True, name="usb_recv")
        self.recv_thread.start()

    def find_endpoint(self):
        ep_out = usb.util.find_descriptor(
            self.interface,
            # match the first OUT endpoint
            custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_OUT)
        self.endpoint_out = ep_out.bEndpointAddress

        ep_in = usb.util.find_descriptor(
            self.interface,
            # match the first IN endpoint
            custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_IN)
        self.endpoint_in = ep_in.bEndpointAddress

    def __recv_entry(self):
        header_ok = False
        recv_buf = bytes()
        buffer = usb.util.create_buffer(MCF_PKT_MAX_SIZE)

        while True:
            try:
                size = self.usb.read(self.endpoint_in, buffer)
            # the buffer len is zero
            except usb.core.USBTimeoutError:
                continue
            except Exception as e:
                logger.error(e)
                del self.link_layer.devices[0].daemon_devices[self.device.pid]
                self.link_layer.devices_destroy(self.device)
                self.usb.reset()
                break
            recv_buf, header_ok = self.usb_link.receive(buffer[:size], recv_buf, header_ok, "usb " + str(self.serial))

    def __usb_recv(self):
        return self.usb_link.transfer_recv()

    def __usb_send(self, pkt, timeout=None):
        frame = self.usb_link.pkt_to_frame(pkt)
        size = len(frame)

        # C type: unsigned int, Byte order: 小端
        msg_type = struct.pack('<I', MCF_USB_MSG_SEND)
        msg_len = struct.pack('<I', size)
        usb_msg = msg_type + msg_len

        self.send_lock.acquire()
        try:
            self.usb.ctrl_transfer(0x21, 0x0a, 0, self.inter_number, usb_msg)
            self.usb.write(self.endpoint_out, frame, timeout=1000)
        except Exception as e:
            self.send_lock.release()
            raise OSError(e)

        self.send_lock.release()
        logger.debug("usb send a frame, len: " + str(len(frame)) + ", data: " + str(frame))
