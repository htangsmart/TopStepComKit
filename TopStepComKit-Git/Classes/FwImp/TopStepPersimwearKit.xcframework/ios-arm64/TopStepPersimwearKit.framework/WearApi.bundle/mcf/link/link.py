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
import time
import logging
import threading
from enum import Enum
from utils.observable import FrameObservable
from utils.observable import Observable
from utils.singleton import singleton

from ..mcf_utils import crc16

LOG_LVL = logging.INFO
LOG_TAG = 'mcf.link'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

MCF_FRAME_HEAD = bytes.fromhex('FC')
MCF_FRAME_END_SIGN = bytes.fromhex('CF')
MCF_FRAME_READ_LEN_LEN = 3
MCF_FRAME_HEAD_LEN = 5
MCF_FRAME_TAIL_LEN = 1
MCF_FRAME_ACK_LEN = 2
MCF_FRAME_MIN_LEN = MCF_FRAME_HEAD_LEN + MCF_FRAME_TAIL_LEN + MCF_FRAME_ACK_LEN

# 链路层
class MCFLinkLayer:
    def __init__(self):
        self.__frame_id = 0
        self.is_executing = False
        # 使用字典保存所有设备
        self.devices = dict()
        self.frame_id = 0
        self.sem = threading.Semaphore(0)
        logger.debug("MCF link layer initialize success")

    # 链路层设备，例如：COM1/TCP:5000
    class Device:
        class LinkType(Enum):
            SOCKET = 0x01
            UART = 0x02
            USB = 0x03

        def __init__(self, pid, link_type, ack, mtu, send, recv, did=0):
            self.pid = pid  # port ID
            # TODO: 支持同一链路的不同端口
            self.free_time = time.time()
            self.did = did
            self.mtu = mtu
            self.send = send
            # 接收链路层设备数据函数（非阻塞模式）
            self.recv = recv
            self.link_type = link_type
            self.support_ack = ack
            self.recv_buf = bytearray()
            self.recv_frames = []
            self.recv_bufsz = mtu * 2
            self.cur_recv_bufsz = 0

            return self

    
    def device_register(self, device):
        logger.debug("register device: {}".format(device))
        self.devices[device.pid] = device

    def devices_destroy(self, device):
        logger.debug("destroy device: {}".format(device))
        try:
            del self.devices[device.pid]
        except Exception as e:
            logger.error(e)

    def device_get_by_did(self):
        pass

    def gen_frame_id(self):
        self.__frame_id += 1
        if self.__frame_id > 255:
            self.__frame_id = 0
        return self.__frame_id

    def send_recv_notice(self):
        self.sem.release()

    def __wait_recv_notice(self, timeout=None):
        self.sem.acquire(timeout=timeout)

    def disconnect(self, pid):
        if pid in self.devices.keys() and hasattr(self.devices[pid], 'disconnect'):
            self.devices[pid].disconnect()

    # 接收链路层数据（阻塞模式）
    def recv(self, timeout=None):
        pkt = bytearray()
        # 接收链路层的消息通知，供上层传输层调用
        self.__wait_recv_notice(timeout)
        for device in list(self.devices.values()):
            pkt = device.recv()
            if len(pkt) > 0:
                device.free_time = time.time()
                # 通知链路检测定时器，重新计时
                FrameObservable().notify_observers(-1)
                return pkt

        return pkt

    # 发送链路层数据（阻塞模式）
    def send(self, pkt, timeout=None):
        """
        根据 pkt 中的 id 判断 device ID
        :param pkt: 待发送的数据包
        :param timeout: send 超时时间
        :return: None
        """

        src_id = pkt[1]
        dst_id = pkt[2]

        # 服务端 
        if 0 in self.devices.keys():
            if dst_id == 254:
                # Client 共用 ID，需要使用 server 分配的 ID
                device_id = pkt[5]
            else:
                device_id = dst_id
        # 客户端
        else:
            device_id = src_id
        try:
            self.devices[device_id].send(pkt, timeout)
            self.devices[device_id].free_time = time.time()
        except Exception as e:
            logger.error("device: %d disconnect, e: %s", device_id, str(e))


class LinkDevice:
    def __init__(self, mtu, recv_frames, link_layer, recv_lock):
        self.mtu = mtu
        self.recv_frames = recv_frames
        self.link_layer = link_layer
        self.recv_lock = recv_lock

    def receive(self, data, recv_buf, header_ok=False, name='', need_crc16=False):
        calc_frame_len = 0
        recv_buf += bytes(data)
        recv_buf_len = len(recv_buf)
        if need_crc16:
            frame_min_len = MCF_FRAME_MIN_LEN
        else:
            frame_min_len = MCF_FRAME_MIN_LEN - MCF_FRAME_ACK_LEN

        while recv_buf_len:
            # 检查帧头及帧长度
            if recv_buf_len >= MCF_FRAME_READ_LEN_LEN and header_ok is False:
                if recv_buf.startswith(MCF_FRAME_HEAD):
                    calc_frame_len = recv_buf[1] * 256 + recv_buf[2]
                    if calc_frame_len > self.mtu or calc_frame_len < frame_min_len:
                        recv_buf = recv_buf[calc_frame_len:]
                        calc_frame_len = len(recv_buf)
                        logger.error("recv frame len is error, self.mtu: {}, cala_len: {}".
                                     format(self.mtu, calc_frame_len))
                        continue
                    else:
                        header_ok = True
                else:
                    recv_buf = bytes()
            # 数据还没有接收完成，退出帧检查
            if recv_buf_len < calc_frame_len or recv_buf_len < MCF_FRAME_READ_LEN_LEN:
                break
            if header_ok and recv_buf_len >= calc_frame_len:
                frame = recv_buf[:calc_frame_len]
                if frame.endswith(MCF_FRAME_END_SIGN) and len(frame) <= self.mtu:
                    # 帧数据接收完成，开始校验
                    verify_ok = True
                    logger.debug("{} recv a frame len: {}, data: {}".format(name, calc_frame_len, str(frame)))
                    if need_crc16:
                        calc_crc = crc16(frame[1:-3])
                        recv_crc = frame[-3] * 256 + frame[-2]
                        if calc_crc != recv_crc:
                            verify_ok = False
                            logger.warning(name + " recv a frame and crc check failed")
                            logger.debug(name + " recv a frame, len: " + str(calc_frame_len) + ", data: " + str(frame))
                    if verify_ok:
                        # 缓存接收帧
                        self.recv_frames.append(frame)
                        # 通知链路层
                        self.link_layer.send_recv_notice()
                # 清理下次帧接收环境
                recv_buf = recv_buf[calc_frame_len:]
                recv_buf_len = len(recv_buf)
                calc_frame_len = len(recv_buf)
                header_ok = False

        return recv_buf, header_ok

    def pkt_to_frame(self, pkt, need_crc16=False):
        pkt_len = len(pkt)

        if need_crc16:
            frame_tail_len = MCF_FRAME_TAIL_LEN + MCF_FRAME_ACK_LEN
        else:
            frame_tail_len = MCF_FRAME_TAIL_LEN

        frame_len = MCF_FRAME_HEAD_LEN + frame_tail_len + pkt_len
        frame = bytearray()
        frame += MCF_FRAME_HEAD
        frame.append(int(frame_len / 256))
        frame.append(frame_len % 256)
        frame.append(self.link_layer.gen_frame_id())
        frame.append(0)
        # 打包 payload
        frame += pkt
        # 打包 CRC
        if need_crc16:
            crc = crc16(frame[1:])
            frame.append(int(crc / 256))
            frame.append(crc % 256)

        frame += MCF_FRAME_END_SIGN

        return frame

    def transfer_recv(self, need_crc16=False):
        payload = bytearray()
        self.recv_lock.acquire()
        if len(self.recv_frames) > 0:
            frame = self.recv_frames.pop(0)
            # calc frame len and pkt len
            frame_len = (frame[1] << 8) | frame[2]
            if need_crc16:
                payload_len = frame_len - MCF_FRAME_HEAD_LEN - MCF_FRAME_TAIL_LEN - MCF_FRAME_ACK_LEN
            else:
                payload_len = frame_len - MCF_FRAME_HEAD_LEN - MCF_FRAME_TAIL_LEN
            # get pkt from frame
            payload = frame[MCF_FRAME_HEAD_LEN:MCF_FRAME_HEAD_LEN + payload_len]
            # may be an error
            assert (len(payload) == payload_len)
        self.recv_lock.release()
        return payload


@singleton
class MCFLinkStatus():
    def __init__(self):
        self.link_status = False

    def set_link_status(self, status):
        logger.info("update mcf link status %d", status)
        self.link_status = status
        LinkLayerObservable().notify_observers(status)

    def get_link_status(self):
        return self.link_status
    
@singleton
class LinkLayerObservable(Observable):
    def __init__(self):
        super().__init__()
