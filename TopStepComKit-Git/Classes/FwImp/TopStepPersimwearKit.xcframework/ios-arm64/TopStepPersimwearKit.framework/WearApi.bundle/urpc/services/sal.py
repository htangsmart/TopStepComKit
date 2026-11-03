#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2022-02-08     armink       the first version
#

import socket, select, random
import struct
import time
from struct import pack

import ubjson
import traceback

from urpc.src.ffi import *

LOG_LVL = logging.DEBUG
LOG_TAG = 'svc.sal'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

class SalSvc:
    def __init__(self, rpc):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        self.rpc.svc_register(rpc.Service("udbd_socket", self.__udbd_socket))
        self.rpc.svc_register(rpc.Service("udbd_connect", self.__udbd_connect))
        self.rpc.svc_register(rpc.Service("udbd_listen", self.__udbd_listen))
        self.rpc.svc_register(rpc.Service("udbd_bind", self.__udbd_bind))
        self.rpc.svc_register(rpc.Service("udbd_accept", self.__udbd_accept))
        self.rpc.svc_register(rpc.Service("udbd_sendto", self.__udbd_sendto))
        self.rpc.svc_register(rpc.Service("udbd_recvfrom", self.__udbd_recvfrom))
        self.rpc.svc_register(rpc.Service("udbd_setsockopt", self.__udbd_setsockopt))
        self.rpc.svc_register(rpc.Service("udbd_shutdown", self.__udbd_shutdown))
        self.rpc.svc_register(rpc.Service("udbd_closesocket", self.__udbd_closesocket))
        self.rpc.svc_register(rpc.Service("udbd_getsockname", self.__udbd_getsockname))
        self.rpc.svc_register(rpc.Service("udbd_getpeername", self.__udbd_getpeername))
        self.rpc.svc_register(rpc.Service("udbd_gethostbyname", self.__udbd_gethostbyname))
        self.rpc.svc_register(rpc.Service("udbd_select", self.__udbd_select))
        self.rpc.svc_register(rpc.Service("udbd_select_wakeup", self.__udbd_select_wakeup))
        self.socket_tbl = dict()
        self.daemon_socket_startup_time = 0
        self.select_wakeup = False

    def __reset_check(self, input):
        # clean the socket table when daemon first login
        if 'startup_time' not in input:
            return
        if input['startup_time'] != self.daemon_socket_startup_time:
            self.daemon_socket_startup_time = input['startup_time']
            for s in self.socket_tbl:
                try:
                    self.socket_tbl[s].shutdown(socket.SHUT_RDWR)
                    self.socket_tbl[s].close()
                    logger.debug("close the legacy socket %d", s)
                except Exception as e:
                    logger.error("close the legacy socket failed: %s", e)
            self.socket_tbl = dict()
            logger.info("daemon was first connect to udb tcp/udp share network, time: %s", time.asctime(time.localtime(input['startup_time'])))

    def __socket_new(self, s):
        retry = 10
        while retry > 0:
            v = random.randint(1, 2147483647)
            if v not in self.socket_tbl:
                self.socket_tbl[v] = s
                return v
            retry = retry - 1
        s.close()
        return -1

    def __socket_find(self, s):
        for k in self.socket_tbl:
            if s is self.socket_tbl[k]:
                return k
        return -1

    def __socket_get(self, v):
        if v in self.socket_tbl:
            return self.socket_tbl[v]
        else:
            return None

    def __ready_get(self, s):
        set_list = []
        if s:
            for i in s:
                set_list.append(self.__socket_find(i))
        return set_list

    def __select_get(self, l):
        set_list = []
        if isinstance(l, list):
            for i in l:
                if isinstance(i, int):
                    s = self.__socket_get(i)
                    if s:
                        set_list.append(s)
        return set_list

    def __socket_delete(self, v):
        return self.socket_tbl.pop(v)

    def __udbd_socket(self, input):
        input = ubjson.loadb(input)
        self.__reset_check(input)
        # Parameter check
        try:
            p_input = str(input)
            p_domain = input['domain']
            p_type = input['type']
            p_input = input['protocol']
        except Exception as e:
            logger.error("socket parameter error:%s\nerror msg:\n%s", p_input, e)
            sock = -1
        else:
            try:
                sock = self.__socket_new(socket.socket(p_domain, p_type, p_input))
            except Exception as e:
                logger.error(str(e))
                sock = -1
            logger.debug("socket(%s, %s, %s) = %s", p_domain, p_type, p_input, sock)
        return sock.to_bytes(4, byteorder='little', signed=True)

    def __udbd_connect(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_host = input['host']
            p_port = input['port']
        except Exception as e:
            logger.error("connect parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                self.__socket_get(p_sock).connect((p_host, p_port))
                result = 0
            except Exception as e:
                logger.error(str(e))
                result = -1
            logger.debug("connect(%s, %s:%s) = %s", p_sock, p_host, p_port, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_listen(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_backlog = input['backlog']
        except Exception as e:
            logger.error("listen parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                self.__socket_get(p_sock).listen(p_backlog)
                result = 0
            except Exception as e:
                logger.error(str(e))
                result = -1
            logger.debug("listen(%s, %s) = %s", p_sock, p_backlog, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_bind(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_host = input['host']
            p_port = input['port']
        except Exception as e:
            logger.error("bind parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                self.__socket_get(p_sock).bind((p_host, p_port))
                result = 0
            except Exception as e:
                logger.error(str(e))
                result = -1
            logger.debug("bind(%s, %s:%s) = %s", p_sock, p_host, p_port, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_accept(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
        except Exception as e:
            logger.error("accept parameter error:%s\nerror msg:\n%s", p_input, e)
            result = {}
        else:
            try:
                s, (host, port) = self.__socket_get(p_sock).accept()
                sock =  self.__socket_new(s)
                result = {"sock": sock, "host": host, "port": port}
            except Exception as e:
                logger.error("accept(%s) error\nerror msg:\n%s", p_sock, e)
                result = {}
            logger.debug("accept(%s) = %s", p_sock, result)
        return ubjson.dumpb(result)

    def __udbd_sendto(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_data = input['data']
            p_flags = input['flags']
            p_host = input.get('host')
            p_port = input.get('port')
        except Exception as e:
            logger.error("sendto parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                if p_host:
                    result = self.__socket_get(p_sock).sendto(p_data, p_flags, (p_host, p_port))
                else:
                    result = self.__socket_get(p_sock).send(p_data, p_flags)
            except Exception as e:
                logger.error(str(e))
                result = -1
            logger.debug("sendto(%s, data=%s, len=%s, %s:%s) = %s", p_sock, p_data, len(p_data), p_host, p_port, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_recvfrom(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_flags = input['flags']
            p_data_len = input['len']
            p_host = input.get('host')
            p_port = input.get('port')
            p_timeout = input.get('timeout')
        except Exception as e:
            logger.error("recvfrom parameter error:%s\nerror msg:\n%s", p_input, e)
            data = bytes()
        else:
            try:
                if p_flags & 0x08 == 0x08:
                    flags = p_flags & ~0x08
                    self.__socket_get(p_sock).setblocking(False)
                else:
                    flags = p_flags
                    self.__socket_get(p_sock).setblocking(True)
                if p_host:
                    self.__socket_get(p_sock).connect((p_host, p_port))
                if p_timeout:
                    timeval = struct.pack('ll', int(p_timeout/1000), (p_timeout%1000)*1000)
                    self.__socket_get(p_sock).setsockopt(socket.SOL_SOCKET, socket.SO_RCVTIMEO, timeval)
                data = self.__socket_get(p_sock).recv(p_data_len, flags)
            except Exception as e:
                logger.error('recvfrom: ' + str(e))
                data = bytes()
            logger.debug("recvfrom(%s, len=%s, %s:%s) = %s", p_sock, p_data_len, p_host, p_port, len(data))
        return data

    def __udbd_setsockopt(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_level = input['level']
            p_optname = input['optname']
            p_optval = bytes(input['optval'])
        except Exception as e:
            logger.error("setsockopt parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            if p_level == 0xfff:
                level = socket.SOL_SOCKET
            if p_optname == 0x1006:
                optname = socket.SO_RCVTIMEO
                optval = pack('ll', int.from_bytes(bytes(p_optval[0:3]), byteorder="little"),
                            int.from_bytes(bytes(p_optval[4:7]), byteorder="little"))
            elif p_optname == 0x1005:
                optname = socket.SO_SNDTIMEO
                optval = pack('ll', int.from_bytes(bytes(p_optval[0:3]), byteorder="little"),
                            int.from_bytes(bytes(p_optval[4:7]), byteorder="little"))

            try:
                self.__socket_get(p_sock).setsockopt(level, optname, optval)
                result = 0
            except Exception as e:
                logger.error('setsockopt: ' + str(e))
                result = -1
            logger.debug("setsockopt(%s, %s, %s, %s) = %s", p_sock, p_level, p_optname, p_optval, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_shutdown(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_how = input['how']
        except Exception as e:
            logger.error("shutdown parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                self.__socket_get(p_sock).shutdown(p_how)
                result = 0
            except Exception as e:
                logger.error('shutdown: ' + str(e))
                result = -1
            logger.debug("shutdown(%s, %s) = %s", p_sock, p_how, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_closesocket(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
        except Exception as e:
            logger.error("closesocket parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                self.__socket_delete(p_sock).close()
                result = 0
            except Exception as e:
                logger.error('shutdown: ' + str(e))
                result = -1
            logger.debug("closesocket(%s) = %s", p_sock, result)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_getsockname(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
        except Exception as e:
            logger.error("closesocket parameter error:%s\nerror msg:\n%s", p_input, e)
            result = {}
        else:
            try:
                host, port = self.__socket_get(p_sock).getsockname()
                result = {"host": host, "port": port}
            except Exception as e:
                logger.error(str(e))
                result = {}
            logger.debug("getsockname(%s) = %s", p_input, result)
        return ubjson.dumpb(result)

    def __udbd_getpeername(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_sock = input['socket']
        except Exception as e:
            logger.error("getpeername parameter error:%s\nerror msg:\n%s", p_input, e)
            result = {}
        else:
            try:
                host, port = self.__socket_get(p_sock).getpeername()
                result = {"host": host, "port": port}
            except Exception as e:
                logger.error(str(e))
                result = {}
            logger.debug("getpeername(%s) = %s", p_sock, result)
        return ubjson.dumpb(result)

    def __udbd_gethostbyname(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_name = input['name']
        except Exception as e:
            logger.error("gethostbyname parameter error:%s\nerror msg:\n%s", p_input, e)
            host = ''
        else:
            try:
                host = socket.gethostbyname(p_name)
            except Exception as e:
                logger.error(str(e))
                logger.error(traceback.format_exc())
                host = ''
            logger.debug("gethostbyname(%s) = %s", p_name, host)
        return host.encode()

    def __udbd_select_sync_block(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_reads = input['reads']
            p_writes = input['writes']
            p_errors = input['errors']
            p_timeout = input['timeout']
        except Exception as e:
            logger.error("select parameter error:%s\nerror msg:\n%s", p_input, e)
            result = {}
        else:
            result = {}
            read_list = self.__select_get(p_reads)
            write_list = self.__select_get(p_writes)
            error_list = self.__select_get(p_errors)
            try:
                rs, ws, es = select.select(read_list, write_list, error_list, p_timeout)
                result["reads"] = self.__ready_get(rs)
                result["writes"] = self.__ready_get(ws)
                result["errors"] = self.__ready_get(es)
            except Exception as e:
                logger.error(str(e))
                result = {}
            logger.debug("select(%s, %s, %s, %s) -> %s", p_reads, p_writes, p_errors, p_timeout, result)
        return ubjson.dumpb(result)

    def __udbd_select_sync_none_block(self, input):
        input = ubjson.loadb(input)
        try:
            p_input = str(input)
            p_reads = input['reads']
            p_writes = input['writes']
            p_errors = input['errors']
            p_timeout = int(input['timeout'])
        except Exception as e:
            logger.error("select parameter error:%s\nerror msg:\n%s", p_input, e)
            result = {}
        else:
            result = {}
            read_list = self.__select_get(p_reads)
            write_list = self.__select_get(p_writes)
            error_list = self.__select_get(p_errors)
            try:
                if p_timeout > 0:
                    delay = 0.1
                    p_timeout = p_timeout * 10
                else:
                    delay = 0
                # 使用 while 循环每阻塞100毫秒，判断一下是否需要退出
                while True:
                    rs, ws, es = select.select(read_list, write_list, error_list, delay)
                    list_rs = self.__ready_get(rs)
                    list_ws = self.__ready_get(ws)
                    list_es = self.__ready_get(es)
                    if len(list_rs) > 0 or len(list_ws) > 0 or len(list_es) > 0:
                        break
                    if p_timeout > 1:
                        p_timeout = p_timeout - 1
                        delay = 0.1
                    else:
                        break
                    if self.select_wakeup is True:
                        self.select_wakeup = False
                        break
                result["reads"] = list_rs
                result["writes"] = list_ws
                result["errors"] = list_es
            except Exception as e:
                logger.error(str(e))
                result = {}
            logger.debug("select(%s, %s, %s, %s) -> %s", p_reads, p_writes, p_errors, p_timeout, result)
        return ubjson.dumpb(result)

    def __udbd_select_wakeup(self, input):
        try:
            self.select_wakeup = True
            result = 0
        except Exception as e:
            logger.error(str(e))
            logger.error(traceback.format_exc())
            result = -1
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_select(self, input):
        try:
            if self.rpc.compare_version("2.4.3") > 0:
                logger.info("Current version is later than 2.4.3, use the <__udbd_select_sync_none_block> interface.")
                return self.__udbd_select_sync_none_block(input)
            else:
                logger.info("Current version is earlier than 2.4.3, use the <__udbd_select_sync_block> interface.")
                return self.__udbd_select_sync_block(input)
        except Exception as e:
            logger.error(str(e))
            logger.error(traceback.format_exc())
            result = {}
            return ubjson.dumpb(result)

