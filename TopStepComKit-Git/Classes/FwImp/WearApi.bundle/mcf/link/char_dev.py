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

import threading

import logging
from .link import MCFLinkLayer
from ..mcf_utils import crc16


LOG_LVL = logging.DEBUG
LOG_TAG = 'mcf.link.char'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

MCF_UART_FRAME_READ_LEN_LEN = 3
MCF_UART_FRAME_HEAD_LEN = 5  # 5 bytes frame header
MCF_UART_FRAME_TAIL_LEN = 3  # 3 bytes frame tail
MCF_UART_FRAME_HEAD = bytes.fromhex('FC')
MCF_UART_FRAME_END_SIGN = bytes.fromhex('CF')
MCF_UART_FRAME_MIN_LEN = MCF_UART_FRAME_HEAD_LEN + MCF_UART_FRAME_TAIL_LEN

g_dev = None
g_output_callback = None


class MCFLinkDeviceChar(MCFLinkLayer.Device):
    def __init__(self, linklayer, pid, ack, mtu):
        global g_dev
        logger.info("g_dev value is None {}".format(g_dev is None))
        # if g_dev is None:
            # 存储全局对象
        g_dev = self

        self.linklayer = linklayer
        self.need_crc16 = crc16
        self.recv_lock = threading.Lock()
        self.send_lock = threading.Lock()
        self.input_lock = threading.Lock()
        self.header_ok = False
        self.recv_buf = bytes()
        self.calc_frame_len = 0
        # 初始化设备
        device = super().__init__(pid, self.LinkType.UART, ack, mtu, self.__send, self.__recv)
        # 注册设备到链路层
        linklayer.device_register(device)
        logger.debug("MCF Char link device register success")

            # TODO 链路层支持 ACK 后，还应该对接上连接&断开的回调

        # else:
        #     logger.warning("alerady inited")

    def update_mtu(self, mtu):
        self.send_lock.acquire()
        self.mtu = mtu - 5
        self.send_lock.release()

    def __recv(self):
        payload = bytearray()
        self.recv_lock.acquire()
        if len(self.recv_frames) > 0:
            frame = self.recv_frames.pop(0)
            # calc frame len and pkt len
            frame_len = (frame[1] << 8) | frame[2]
            payload_len = frame_len - MCF_UART_FRAME_HEAD_LEN - MCF_UART_FRAME_TAIL_LEN
            # get pkt from frame
            payload = frame[MCF_UART_FRAME_HEAD_LEN:MCF_UART_FRAME_HEAD_LEN + payload_len]
            # may be an error
            assert (len(payload) == payload_len)
        self.recv_lock.release()
        return payload

    def __send(self, pkt, timeout=None):
        if g_dev is not None and g_output_callback is not None:
            pkt_len = len(pkt)
            frame_len = MCF_UART_FRAME_HEAD_LEN + MCF_UART_FRAME_TAIL_LEN + pkt_len
            frame = bytearray()
            frame += MCF_UART_FRAME_HEAD
            frame.append(int(frame_len / 256))
            frame.append(frame_len % 256)
            frame.append(self.linklayer.gen_frame_id())
            frame.append(0)
            # 打包 payload
            frame += pkt
            # 打包 CRC
            if self.need_crc16:
                crc = crc16(frame[1:])
                frame.append(int(crc / 256))
                frame.append(crc % 256)
            # 打包帧尾
            frame += MCF_UART_FRAME_END_SIGN

            self.send_lock.acquire()

            sub_frame_id = 0
            sub_frame_index = 0
            while len(frame) - sub_frame_index > 0:
                sub_frame = frame[sub_frame_index:sub_frame_index + self.mtu]
                if len(frame) <= self.mtu:
                    logger.debug("send a frame, len: %s, data: %s", len(sub_frame), sub_frame.hex(' '))
                else:
                    if sub_frame_id == 0:
                        logger.debug("send a frame[%d], len: %s, data: %s", sub_frame_id,
                                    len(sub_frame), sub_frame.hex(' '))
                g_output_callback(sub_frame)
                sub_frame_id += 1
                sub_frame_index += len(sub_frame)

            self.send_lock.release()


def porting_input(data):
    if g_dev is not None:
        g_dev.input_lock.acquire()
        try:
            frame_check_main(data)
        except Exception as e:
            logger.error(e)
        g_dev.input_lock.release()

def frame_check_main(data):
    logger.debug("char.input %d, total: %d, data: %s", len(bytes(data)), len(g_dev.recv_buf) + len(bytes(data)), bytes(data).hex(' '))

    recv_buf = bytes(data) # 暂存数据

    if recv_buf.startswith(MCF_UART_FRAME_HEAD):  # 以帧头开始
        if recv_buf.endswith(MCF_UART_FRAME_END_SIGN): # 以帧尾结束
            # 以帧头 fc 开头, cf 结尾， 校验是否为单独的数据帧
            is_complete_frame = check_complete_frame(recv_buf)

            if is_complete_frame: # 判定为单独的数据帧，丢弃缓冲区内数据
                if len(g_dev.recv_buf):
                    logger.error("recv complete frame, throw away buf frame %s", bytes(g_dev.recv_buf).hex(' '))
                g_dev.recv_buf = bytes()
                g_dev.recv_buf += recv_buf
                g_dev.recv_lock.acquire()
                g_dev.recv_frames.append(g_dev.recv_buf)
                g_dev.recv_lock.release()
                # 通知链路层
                g_dev.linklayer.send_recv_notice()
                # 上报链路层之后，清除缓冲区
                g_dev.recv_buf = bytes()
                g_dev.calc_frame_len = 0
            else: # 不是完整的数据帧，判定为中间数据帧
                """
                    将接收到到数据帧和缓冲区内的数据进行拼接，
                    拼接后需要校验数据长度和 crc 
                    长度不对进行智能恢复
                """
                data_len = 0
                if len(g_dev.recv_buf) == 0:
                    # 缓冲区没有数据，将当前数据帧作为起始帧
                    data_len = calc_frame_len(recv_buf)
                else:
                    data_len = calc_frame_len(g_dev.recv_buf)
                if not check_mult_frame_adhesion(recv_buf):
                    deal_frame_check_result(check_recv_buf(g_dev.recv_buf, recv_buf, data_len))
        else:
            """
                不是以帧尾结束
                    ==> 起始数据帧
                        ==> 计算数据包长度等
                    ==> 中间数据帧
                        ==> 数据帧拼接，校验数据帧
            """
            if len(g_dev.recv_buf) != 0: # 缓冲区内有数据， 判定为中间数据帧
                deal_frame_check_result(check_recv_buf(g_dev.recv_buf, recv_buf, g_dev.calc_frame_len))
            else: #  缓冲区内没有数据， 判定为起始数据帧，存入缓冲区
                g_dev.recv_buf = bytes()
                g_dev.recv_buf += recv_buf
                g_dev.calc_frame_len = calc_frame_len(recv_buf)
    else: # 非帧头开头，判定为中间数据帧
        if not len(g_dev.recv_buf):
            # 缓冲区没有数据，出错
            logger.error("recv frame error")
            return
        deal_frame_check_result(check_recv_buf(g_dev.recv_buf, recv_buf, g_dev.calc_frame_len))



def deal_frame_check_result(result):
    if result[0]:
        g_dev.recv_buf = result[2]
        g_dev.calc_frame_len = calc_frame_len(g_dev.recv_buf)
        if result[1]:
            frame = g_dev.recv_buf[:g_dev.calc_frame_len]
            # 已经是完整的数据包， 上报链路层
            g_dev.recv_lock.acquire()
            g_dev.recv_frames.append(frame)
            g_dev.recv_lock.release()
            # 通知链路层
            g_dev.linklayer.send_recv_notice()
            g_dev.recv_buf = bytes()
            g_dev.calc_frame_len = 0
            if len(result[3]):
                # 处理完之后还有下一包数据,递归处理
                frame_check_main(result[3])
        else: # 不是完整的数据帧，还有数据未接收完
            pass

    else: # 数据帧校验出错
        g_dev.recv_buf = bytes()
        g_dev.calc_frame_len = 0
        if len(result[3]):
            g_dev.recv_buf = [] 
            g_dev.calc_frame_len = 0
            frame_check_main(result[3])
            return
        logger.error("check frame error")
        
        

# 在帧头帧尾都满足，但是长度或者 crc 校验不通过的情况下，检查是否存在多包粘连的情况
"""
1. 计算的帧长度小于接收的帧长
2. 计算的帧长度大于接收的帧长
3. 帧长相同，crc 校验失败
"""
def check_mult_frame_adhesion(frame):
    __calc_frame_len = calc_frame_len(frame)
    __recv_frame_len = len(frame)
    if __calc_frame_len < __recv_frame_len:
        # 存在多包粘连的情况
        tmp_buf = bytes()
        tmp_buf += frame[:__calc_frame_len] # 截取数据
        # 递归处理
        frame_check_main(tmp_buf)
        frame_check_main(frame[__calc_frame_len:])
        return True
    elif __calc_frame_len > __recv_frame_len:
        # 计算的数据大于接收到的数据， 判定为中间数据包，交由 check_recv_buf 校验数据
        return False





# 计算帧长度
def calc_frame_len(frame):
    return frame[1] * 256 + frame[2]


# 校验是否为单独的数据帧
def check_complete_frame(frame):
    """
    校验帧长和 crc16
    """
    frame_len = calc_frame_len(frame) # 从数据帧中计算长度
    if frame_len != len(frame):
        # 计算出出来的数据帧长度和接收到的数据帧长度不相等， 判定为不是单独的数据帧
        logger.warning("recv a frame but frame length check error, should recv %s , recv frame length %s", frame_len, len(frame))
        return False
    # 数据长度校验通过，校验 crc
    pkt = frame[1:-3] # 截取去除帧头、 crc、 帧尾后的数据

    calc_crc = crc16(pkt)

    recv_crc = frame[-3] * 256 + frame[-2] 

    if calc_crc != recv_crc: # crc 校验不通过
        logger.error("recv a frame and crc check error")
        return False
    
    return True # 判定为单独且完整的数据

# 将当前接收到的数据帧和缓冲区的数据进行拼接并进行校验
# 返回校验结果和处理后的数据帧
# 返回结果格式 [校验结果, 是否为完整的数据帧, 拼接后的数据帧, 恢复后剩余数据帧]
def check_recv_buf(recv_buf, cur_frame, calc_frame_len):
    tmp_buf = bytes()
    tmp_buf += recv_buf # 缓冲区中数据
    tmp_frame_len = len(tmp_buf) + len(cur_frame)
    if tmp_frame_len < calc_frame_len:
        # 接收到的数据长度小于计算的长度，判定为数据未接收完成
        tmp_buf += cur_frame
        return [True, False, tmp_buf, bytes()]
    # 接收到的数据长度大于等于计算的数据长度
    elif tmp_frame_len == calc_frame_len:
        tmp_buf += cur_frame
        # 接收到的数据长度等于计算的长度，判定为数据接收完成
        if tmp_buf.endswith(MCF_UART_FRAME_END_SIGN):
            # 校验数据帧
            if check_complete_frame(tmp_buf):
                # 完整的数据帧，
                return [True, True, tmp_buf, bytes()]
            else: ## 数据帧接收错误
                return [False, False, bytes(), bytes()]
        # 数据帧不以帧尾结尾
        return [False, True, bytes(), bytes()]
    elif tmp_frame_len > calc_frame_len: # 接收到的数据帧长度大于计算的长度，截取一部分进行拼接

        # 这里要分两种情况
        # 1. 缓冲区内的数据长度已经大于计算的数据长度
        # 2. 缓冲区内的数据长度加上当前接收到的数据长度大于计算的数据长度

        # 使用统一的截取方式
        # 先拼接数据，然后在进行截取

        tmp_full_buf = tmp_buf + cur_frame

        # 从全部的数据中，截取计算的数据长度

        tmp_buf = tmp_full_buf[:calc_frame_len]

        # 剩余数据

        remain_buf = tmp_full_buf[calc_frame_len:]

        if check_complete_frame(tmp_buf):
            return [True, True, tmp_buf, remain_buf]
        else: # 
            # 如果截取的数据帧校验不通过，则丢弃，校验剩余数据
            if remain_buf.startswith(MCF_UART_FRAME_HEAD):
                # 帧头开头，判定为另外一包数据的起始帧
                return [False, False, bytes(), remain_buf]
            return [False, False, bytes(), bytes()]



# 设置设备底层输出回调接口
def porting_set_output_callback(output):
    global g_output_callback
    g_output_callback = output
