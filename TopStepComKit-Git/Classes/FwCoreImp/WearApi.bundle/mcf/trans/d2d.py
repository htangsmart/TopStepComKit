#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2020-11-15     armink       the first version
#
import logging
from concurrent.futures.thread import ThreadPoolExecutor
from enum import Enum

from ..mcf_utils import MCFSendException
from .event import DataEvent
from ..mcf import MCF_PKT_MAX_SIZE, MCF_ACK_TIMOUT, MCF_REQ_RERTY_TIMES, MCF_ACK_RERTY_TIMES
from .packet import TransPacket
import traceback
from utils.observable import Observer
from mcf.link.link import LinkLayerObservable

LOG_LVL = logging.INFO
LOG_TAG = 'mcf.d2d'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

# D2D broadcast device id
D2D_DEV_ID_BROADCAST = 255
# D2D packet header length (4 bytes)
D2D_PKT_HEAD_LEN = 4
# D2D packet buffer max
D2D_PKT_MAX_SIZE = (MCF_PKT_MAX_SIZE + D2D_PKT_HEAD_LEN)


class D2DProto:
    def __init__(self, translayer, did):
        self.translayer = translayer
        self.did = did
        self.pkt_id = 0
        self.req_fun = self.__default_req_fun
        self.pkt_events = DataEvent()
        self.executor = ThreadPoolExecutor(max_workers=64)
        LinkLayerObservable().add_observer(self.D2dLinkStatusObserver(self))

    class D2dLinkStatusObserver(Observer):
        def __init__(self, d2d):
            super().__init__()
            self.d2d = d2d
        def update(self, data):
            if not data:
                logger.error("link disconnect, clear event")
                self.d2d.pkt_events.clear()

    def __default_req_fun(self, payload):
        return payload

    def set_req_fun(self, fun):
        self.req_fun = fun

    def __pkt_send(self, pkt, timeout=None, retry=0, non_block=False):
        # 打包
        raw_pkt = pkt.pack()
        trans_pkt = TransPacket(TransPacket.Type.D2D, raw_pkt)
        raw_pkt = trans_pkt.pack()
        self.pkt_events.create(pkt.id)
        while True:
            # 发送
            logger.debug("send a %s pkt (id:%d, len:%2d) to   %d", pkt.type, pkt.id, pkt.len, pkt.dst_id)
            self.translayer.send(raw_pkt, timeout, non_block)
            # ACK 处理
            if pkt.type != D2DPacket.Type.ACK and (
                    pkt.need_ack and (pkt.type == D2DPacket.Type.REQ or pkt.type == D2DPacket.Type.RSP)):
                recv_ack_pkt = self.pkt_events.wait(pkt.id, MCF_ACK_TIMOUT)
                self.pkt_events.delete(pkt.id)
                if recv_ack_pkt is None and retry > 0:
                    logger.warning("wait d2d %s ACK pkt (id:%d) timeout (%sS), remain retry %d", pkt.type, pkt.id,
                                   MCF_ACK_TIMOUT, retry)
                    retry -= 1
                    continue
                elif retry == 0:
                    raise MCFSendException()
            return

    def __ack_pkt_send(self, dst_id, src_id, pkt_id, timeout=None):
        ack_pkt = D2DPacket(dst_id, src_id, pkt_id, D2DPacket.Type.ACK, False, False, 0, 0, bytearray())
        self.__pkt_send(ack_pkt, timeout)

    def __broadcast_pkt_send(self, pkt, timeout=None):
        # TODO 广播至所有的底层链路
        pass

    def send(self, pkt, timeout=None, non_block=False):
        if pkt.dst_id == D2D_DEV_ID_BROADCAST:
            self.__broadcast_pkt_send(pkt, timeout)
            return
        self.__pkt_send(pkt, timeout, MCF_REQ_RERTY_TIMES, non_block)

    def recv(self, send_pkt, timeout=None):
        recv_pkt = self.pkt_events.wait(send_pkt.id, timeout)
        if recv_pkt is not None and recv_pkt.need_ack:
            self.__ack_pkt_send(send_pkt.dst_id, send_pkt.src_id, send_pkt.id)
        elif recv_pkt is None and timeout is not None:
            logger.warning("wait d2d response pkt (id:%d) timeout (%f)", send_pkt.id, timeout)
            logger.error(str(traceback.format_stack()))


        self.pkt_events.delete(send_pkt.id)

        return recv_pkt

    def __exec_request(self, in_pkt):
        try:
            # 回复 ACK
            if in_pkt.need_ack:
                self.__ack_pkt_send(in_pkt.src_id, in_pkt.dst_id, in_pkt.id)
            # 执行业务
            payload = self.req_fun(in_pkt.payload)
            # 回复响应
            if in_pkt.need_rsp:
                out_pkt = D2DPacket(in_pkt.src_id, in_pkt.dst_id, in_pkt.id, D2DPacket.Type.RSP, in_pkt.need_ack, False,
                                    in_pkt.priority, in_pkt.reserve, payload)
                self.__pkt_send(out_pkt, retry=MCF_ACK_RERTY_TIMES)
        except MCFSendException:
            logger.error("response send error")
        except Exception as e:
            logger.error(traceback.format_exc())

    def pkt_gen(self, dst_id, type, need_ack=False, need_rsp=False, priority=0, payload=None):
        assert (dst_id != self.did)
        pkt = D2DPacket(dst_id, self.did, self.pkt_id, type, need_ack, need_rsp, priority, 0, payload)
        self.pkt_id += 1
        if self.pkt_id > 255:
            self.pkt_id = 0

        return pkt

    def parser(self, trans_pkt):
        # 从链路层报文解析为传输层报文
        d2d_pkt = D2DPacket()
        d2d_pkt.unpack(trans_pkt)
        logger.debug("recv a %s pkt (id:%d, len:%2d) from %d", d2d_pkt.type, d2d_pkt.id, d2d_pkt.len, d2d_pkt.dst_id)
        pkt_type = d2d_pkt.pkt_type_get(self.did)
        # 传输层业务处理
        if pkt_type == D2DPacket.Type.PROXY:
            # 代理转发模式的处理
            self.__pkt_send(d2d_pkt)
        elif pkt_type == D2DPacket.Type.BROADCAST:
            # TODO 广播模式的处理
            pass
        elif pkt_type == D2DPacket.Type.REQ:
            # 请求模式的处理
            # 使用线程池，执行请求业务
            self.executor.submit(self.__exec_request, d2d_pkt)
        elif pkt_type == D2DPacket.Type.RSP:
            # 响应模式的处理
            self.pkt_events.notice(d2d_pkt.id, d2d_pkt)
        elif pkt_type == D2DPacket.Type.ACK:
            # 请求 ACK 模式的处理
            self.pkt_events.notice(d2d_pkt.id, d2d_pkt)
        else:
            logger.error("not supported packet type (%s)", pkt_type)


class D2DPacket:
    class Type(Enum):
        REQ = 0
        RSP = 1
        ACK = 2
        BROADCAST = 3
        PROXY = 4
        MAX = 5

    class Index(Enum):
        SRC_ID = 0
        DST_ID = 1
        PKT_ID = 2
        ATTR1 = 3
        ATTR2 = 4
        RESERVE = 5

    def __init__(self, dst_id=0, src_id=0, id=0, type=0, need_ack=False, need_rsp=False, priority=0, reserve=0,
                 payload=None):
        self.need_rsp = need_rsp
        self.need_ack = need_ack
        self.reserve = reserve
        self.payload = payload
        pyload_len = 0 if payload is None else len(payload)
        self.len = D2D_PKT_HEAD_LEN + pyload_len
        self.priority = priority
        self.type = type
        self.id = id
        self.src_id = src_id
        self.dst_id = dst_id

    def pack(self):
        # 打包包头，参考如下 C 代码
        # buffer[MCF_D2D_PKT_INDEX_SRC_ID] = pkt->src_id;
        # buffer[MCF_D2D_PKT_INDEX_DST_ID] = pkt->dst_id;
        # buffer[MCF_D2D_PKT_INDEX_PKT_ID] = pkt->pkt_id;
        # buffer[MCF_D2D_PKT_INDEX_PKT_INFO] = (pkt->pkt_type << 6) | (pkt->need_ack << 5) | \
        #                                      (pkt->need_rsp << 4) | (pkt->priority << 2) | pkt->reserve;
        raw_pkt = bytearray()
        raw_pkt.append(self.src_id)
        raw_pkt.append(self.dst_id)
        raw_pkt.append(self.id)
        need_rsp = 1 if self.need_rsp else 0
        need_ack = 1 if self.need_ack else 0
        raw_pkt.append((self.type.value << 6) | (need_ack << 5) | (need_rsp << 4) | ((self.priority & 0x03) << 2) | (
                    self.reserve & 0x03))

        # 打包 payload
        raw_pkt += self.payload
        return raw_pkt

    def unpack(self, raw_pkt):
        # 解包包头，参考如下 C 代码
        # pkt->src_id = buffer[MCF_D2D_PKT_INDEX_SRC_ID];
        # pkt->dst_id = buffer[MCF_D2D_PKT_INDEX_DST_ID];
        # pkt->pkt_id = buffer[MCF_D2D_PKT_INDEX_PKT_ID];
        # pkt->pkt_type = (buffer[MCF_D2D_PKT_INDEX_PKT_INFO] >> 6);
        # pkt->need_ack = (buffer[MCF_D2D_PKT_INDEX_PKT_INFO] >> 5) & 0x1;
        # pkt->need_rsp = (buffer[MCF_D2D_PKT_INDEX_PKT_INFO] >> 4) & 0x1;
        # pkt->priority = (buffer[MCF_D2D_PKT_INDEX_PKT_INFO] >> 2) & 0x3;
        # pkt->reserve = (buffer[MCF_D2D_PKT_INDEX_PKT_INFO] & 0x3);
        self.src_id = raw_pkt[0]
        self.dst_id = raw_pkt[1]
        self.id = raw_pkt[2]
        self.type = self.Type((raw_pkt[3] >> 6))
        need_ack = (raw_pkt[3] >> 5) & 0x01
        need_rsp = (raw_pkt[3] >> 4) & 0x1
        self.need_ack = False if need_ack == 0 else True
        self.need_rsp = False if need_rsp == 0 else True
        self.priority = (raw_pkt[3] >> 2) & 0x3
        self.reserve = raw_pkt[3] & 0x3
        self.len = len(raw_pkt)
        # 解包 payload
        payload_len = len(raw_pkt) - D2D_PKT_HEAD_LEN
        self.payload = raw_pkt[D2D_PKT_HEAD_LEN:D2D_PKT_HEAD_LEN + payload_len]
        return payload_len

    def pkt_type_get(self, did):
        if self.dst_id == 0xFF:
            return self.Type.BROADCAST
        # D2D packet is proxy packet
        elif self.dst_id != did:
            return self.Type.PROXY
        else:
            return self.Type(self.type)
