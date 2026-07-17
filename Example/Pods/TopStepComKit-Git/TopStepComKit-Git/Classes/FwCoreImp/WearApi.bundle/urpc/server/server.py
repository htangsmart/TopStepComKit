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
import logging
import os
import sys
import json
import threading
import configparser
import socket
import random
import time

from pathlib import Path

from urpc.services.sal import SalSvc
from urpc.src.ffi import *
from urpc.src.urpc import uRPC
from mcf.link.link import MCFLinkLayer
from mcf.mcf import MCF_PKT_MAX_SIZE
from mcf.trans.trans import MCFTransLayer
from mcf.link.socket_tcp import MCFLinkDeviceSocket
from urpc.server.daemon import DaemonCmd


LOG_LVL = logging.INFO
LOG_TAG = 'udb.server.server'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

#  server 设备管理：
#  255：广播包
#  0: server
#  1： daemon
#  client 可用端口 2 - 254
#


def get_current_path():
    dir_path = ""
    if getattr(sys, 'frozen', False):
        dir_path = os.path.dirname(sys.executable)
    elif __file__:
        dir_path = os.path.dirname(__file__)
    return dir_path


class UdbServer(MCFLinkLayer.Device):
    def __init__(self, link_layer, port):
        self.daemon_devices = dict()
        # TODO: 目前 daemon 设备固定 did 为 1
        self.did = 1
        self.rpc = None
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind(('0.0.0.0', port))
        self.server.listen(5)
        self.link_layer = link_layer
        device = super().__init__(0, self.LinkType.SOCKET, True, MCF_PKT_MAX_SIZE,
                                  self.__socket_send, self.__socket_recv)

        link_layer.device_register(device)

        timer = threading.Thread(target=self.daemon_heartbeat_timer, daemon=True, name="heartbeat_thread")
        timer.start()
        logger.info('Udb Server Start finish')

    def run(self, rpc):
        self.rpc = rpc
        while True:
            # 等待 client 连接
            conn, addr = self.server.accept()
            # 检查 daemon 状态
            device = DaemonCmd(link_layer=self.link_layer, rpc=rpc, daemon_devices=self.daemon_devices)
            ini_file_path = Path(get_current_path()).joinpath("udb.ini")
            serial = device.search(ini_file_path)
            for did, port in serial.items():
                daemon = dict()
                if not did:
                    continue
                if did not in self.daemon_devices.keys():
                    daemon["support_ack"] = self.link_layer.devices[int(did)].support_ack
                    daemon["port"] = port
                    self.daemon_devices[did] = daemon

            client_port = conn.getpeername()[1]

            while True:
                # 生成 client did  64 <= did <= 128
                if len(list(self.link_layer.devices.keys())[64:128]) >= 64:
                    logger.error("Server no assigned ID to the client")
                    return

                self.did = random.randint(64, 128)
                if self.did not in self.link_layer.devices.keys():
                    break

            MCFLinkDeviceSocket(self.link_layer, conn, client_port, self.did)
            logger.debug("device: {}".format(self.link_layer.devices))

    @staticmethod
    def __socket_recv():
        payload = bytearray()
        return payload

    def __socket_send(self, pkt, timeout=None):
        pass

    def devices(self, args):
        try:
            pkt = bytearray(json.dumps(self.daemon_devices), encoding="utf8")
            logger.debug(pkt)
        except Exception as e:
            logger.error(e)
            pkt = bytearray(0)

        return pkt

    def distribute_id(self, args):
        """
        服务端分发 device ID
        :return:
        """
        logger.debug("distribute id: {}".format(self.did))
        pkt = int.to_bytes(self.did, length=1, byteorder='big', signed=False)

        return pkt

    def daemon_heartbeat_timer(self):
        """
        daemon 心跳定时器：server 在 daemon 空闲时发送请求包，如果 daemon 没有响应，判断 daemon 离线，从当前 udb 链路删除。
        :param
        """
        while True:
            ping = Arg(U8, 0xFF)
            for daemon in list(self.daemon_devices.keys()):
                if time.time() - self.link_layer.devices[daemon].free_time > 5:
                    try:
                        self.rpc.exec_ffi_func(int(daemon), "_ping", [ping], need_ack=False,
                                               need_rsp=True, timeout=10)
                    except Exception as e:
                        logger.error(e)
                        logger.error("daemon: {} heartbeat overtime.".format(self.daemon_devices[daemon]["port"]))
                        del self.daemon_devices[daemon]
                        self.link_layer.devices_destroy(self.link_layer.devices[daemon])
            time.sleep(5)

    @staticmethod
    def connect(args):
        """
        注册串口
        :param args: port: com1; baudrate: 115200
        :return:
        """
        try:
            args = json.loads(str(args, 'utf-8'))
            port = args["port"]
            baudrate = int(args["baudrate"])
        except Exception as e:
            logger.error(e)
            return int.to_bytes(0, length=1, byteorder='big', signed=False)

        logger.debug("port: {}, baudrate: {}".format(port, baudrate))

        ini_file_path = Path(get_current_path()).joinpath("udb.ini")
        udb_config_parser = configparser.ConfigParser()
        udb_config_parser.read(ini_file_path)
        if "SERIAL" not in udb_config_parser.sections():
            udb_config_parser.add_section("SERIAL")
        udb_config_parser.set("SERIAL", "port", port)
        udb_config_parser.set("SERIAL", "baudrate", str(baudrate))
        udb_config_parser.write(open(ini_file_path, "w+"))

        return int.to_bytes(1, length=1, byteorder='big', signed=False)

    def disconnect(self, args):
        """
        断开串口
        :param args:
        :return:
        """
        pass

    @staticmethod
    def kill_server(args):
        """
        kill udb server 进程
        :return: None
        """
        # TODO: kill 之前需要做一些处理。shell: 发送结束命令；write: 发送 close 命令
        os.kill(os.getpid(), 9)


def start(port=41729):
    # 初始化 rpc 服务
    link_layer = MCFLinkLayer()
    udb_server = UdbServer(link_layer, port)
    trans_layer = MCFTransLayer(link_layer, 0)
    rpc = uRPC(trans_layer)
    # 注册本地服务
    rpc.svc_register(rpc.Service("devices", udb_server.devices))
    rpc.svc_register(rpc.Service("connect", udb_server.connect))
    rpc.svc_register(rpc.Service("disconnect", udb_server.disconnect))
    rpc.svc_register(rpc.Service("distribute_id", udb_server.distribute_id))
    rpc.svc_register(rpc.Service("kill_server", udb_server.kill_server))
    # 注册 SAL 本地服务
    SalSvc(rpc)
    # 启动 server 进程
    udb_server.run(rpc)


if __name__ == '__main__':
    start()
