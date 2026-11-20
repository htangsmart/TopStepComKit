#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2021-06-08     liukang      the first version
#

import json
import logging

from urpc.src.ffi import *


LOG_LVL = logging.INFO
LOG_TAG = 'device'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


DEVICE_STATE = ["active", "offline"]


class DeviceCmd:
    def __init__(self, rpc=None, link_layer=None):
        self.rpc = rpc
        self.link_layer = link_layer
        self.daemon_device = dict()
        self.dst_id = 0
        self.block_size = 0

    def get_id(self):
        """
        向 server 申请 device id
        :return: None
        """
        try:
            svc = DeviceSvc(self.rpc)
            result = svc.ds_id()
        except Exception as e:
            logger.error(e)
            return None
        if not result:
            return None

        logger.debug("client login success. did: {}".format(result))
        return int(result)

    def list(self, daemon_list):
        """
        向 server 获取 daemon 列表
        :return: None
        """
        try:
            svc = DeviceSvc(self.rpc)
            daemon_device = svc.ds_list()
        except Exception as e:
            logger.error(e)
            return False

        if not daemon_device:
            logger.debug("no daemon in udb link.")
            return False

        device_info = 'List of devices attached\n'
        device_info += "{:<15}{:<15}{:<15}{:<15}\n".format('serial', 'mtu', 'version', 'state')
        for dst_id, dst_info in daemon_device.items():
            device = dict()
            if not daemon_device[dst_id]['connect']:
                continue
            mtu = self.mtu(int(dst_id))
            version = self.version(int(dst_id))
            zlib = self.zlib(int(dst_id))
            state = DEVICE_STATE[1]
            if mtu and version:
                state = DEVICE_STATE[0]
            device_info += '{:<15}{:<15}{:<15}{:<15}\n'.format(dst_info["port"], mtu, version, state)
            try:
                device["mtu"] = int(mtu)
                device["version"] = version
                device["zlib"] = zlib
                device["state"] = state
                device["id"] = int(dst_id)
                device["support_ack"] = dst_info["support_ack"]
            except Exception as e:
                device = dict()

            self.daemon_device[dst_info["port"]] = device

        if daemon_list:
            print(device_info)

        return self.daemon_device

    def connect(self, port, baudrate):
        """
        向 server 发送 com 设备信息
        :param port: com 端口号
        :param baudrate: com 波特率
        :return: None
        """
        try:
            svc = DeviceSvc(self.rpc)
            svc.ds_connect(port, baudrate)
        except Exception as e:
            logger.error(e)

    def disconnect(self, port):
        try:
            svc = DeviceSvc(self.rpc)
            svc.ds_disconnect(port)
        except Exception as e:
            logger.error(e)

    def kill_server(self):
        """
        杀掉 server 进程
        :return: None
        """
        try:
            svc = DeviceSvc(self.rpc)
            svc.ds_kill_server()
        except Exception as e:
            logger.error(e)

    def mtu(self, dst_id=1):
        """
        获取 dst_id 设备 MTU
        :param dst_id: daemon id
        :return: mtu
        """
        serial_mtu = ''
        try:
            key = "udbd.mtu\0"
            key = Arg(U8 | ARRAY, key.encode())
            buffer = Arg(U8 | ARRAY | EDITABLE, list(range(32)))
            result = self.rpc.exec_ffi_func(dst_id, "_dev_info", [key, buffer], need_ack=False,
                                            need_rsp=True, timeout=2, retry = 1)
            if result.value == 0:
                return 0
            else:
                for i in buffer.value[0:result.value]:
                    serial_mtu += chr(i)
                self.rpc.block_size = int(serial_mtu)
            return serial_mtu

        except Exception as e:
            # 捕获异常, 链路已断开
            logger.error("link disconnected.")
            return serial_mtu

    def version(self, dst_id=1):
        """
        获取 dst_id daemon 设备版本
        :param dst_id: daemon id
        :return: version
        """
        serial_ver = ''
        key = "udbd.ver\0"
        key = Arg(U8 | ARRAY, key.encode())
        buffer = Arg(U8 | ARRAY | EDITABLE, list(range(32)))
        try:
            result = self.rpc.exec_ffi_func(dst_id, "_dev_info", [key, buffer], need_ack=False,
                                            need_rsp=True, timeout=2, retry = 1)
        except Exception as e:
            # 捕获异常, 链路已断开
            logger.error("link disconnected.")
            return serial_ver

        if result.value == 0:
            return 0

        for i in buffer.value[0:result.value]:
            serial_ver += chr(i)

        return serial_ver

    def zlib(self, dst_id=1):
        """
        获取 dst_id daemon 设备版本
        :param dst_id: daemon id
        :return: version
        """
        zlib_support = ''
        key = "udbd.zlib.decompress\0"
        key = Arg(U8 | ARRAY, key.encode())
        buffer = Arg(U8 | ARRAY | EDITABLE, list(range(32)))
        try:
            result = self.rpc.exec_ffi_func(dst_id, "_dev_info", [key, buffer], need_ack=False,
                                            need_rsp=True, timeout=2, retry = 1)
        except Exception as e:
            # 捕获异常, 链路已断开
            logger.error("link disconnected.")
            return False

        if result.value == 0:
            return False

        for i in buffer.value[0:result.value]:
            zlib_support += chr(i)
        if zlib_support == "False":
            zlib_support = False
        else:
            zlib_support = True

        return zlib_support


class DeviceSvc:
    def __init__(self, rpc):
        self.rpc = rpc
        logger.debug("Device class init ok")

    def ds_list(self):
        try:
            result = self.rpc.exec_svc(0, "devices", need_rsp=True, need_ack=False, timeout=10)
        except Exception as e:
            return None

        result = result.decode('utf-8')
        daemon_devices = json.loads(result)
        logger.debug("client recv data from server: {}".format(result))

        return daemon_devices

    def ds_id(self):
        """
        向 server 申请 did
        :return: 可用的 did
        """
        pkt = int.to_bytes(0, length=1, byteorder='big', signed=False)

        try:
            result = self.rpc.exec_svc(0, "distribute_id", pkt, need_rsp=True, need_ack=False, timeout=10)
        except Exception as e:
            logger.error(e)
            return False

        did = int.from_bytes(result, byteorder='big', signed=False)
        logger.debug("device get id: {}".format(did))

        return did

    def ds_connect(self, port, baudrate):

        args = {"port": port, "baudrate": baudrate}
        args = bytearray(json.dumps(args), encoding="utf8")
        logger.debug("pkt: {}".format(args))

        try:
            result = self.rpc.exec_svc(0, "connect", args, need_rsp=True, need_ack=False, timeout=10)
        except Exception as e:
            logger.error(e)

        logger.debug("ds connect result: {}".format(result))

        return result

    def ds_disconnect(self, port):

        args = {"port": port}
        args = bytearray(json.dumps(args), encoding="utf8")
        logger.debug("pkt: {}".format(args))

        try:
            result = self.rpc.exec_svc(0, "disconnect", args, need_rsp=True, need_ack=False, timeout=1)
        except Exception as e:
            logger.error(e)

        logger.debug("ds disconnect result: {}".format(result))

        return result

    def ds_kill_server(self):
        try:
            self.rpc.exec_svc(0, "kill_server", need_rsp=False, need_ack=False, timeout=1)
        except Exception as e:
            logger.error(e)

        return None

    def ds_heartbeat(self):
        try:
            self.rpc.exec_svc(0, "heartbeat", need_rsp=True, need_ack=False, timeout=1)
        except Exception as e:
            raise Exception(e)
        return True
