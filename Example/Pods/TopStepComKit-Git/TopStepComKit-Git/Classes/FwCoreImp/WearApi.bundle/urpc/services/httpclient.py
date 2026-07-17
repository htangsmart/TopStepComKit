#!/user/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2020, RT-Thread Development Team
#
# SPDX-License-Identifier: Apache-2.0
#
# Change Logs:
# Date           Author       Notes
# 2023-03-07     armink       the first version
#
import http.client
import random
import time
import traceback
from urllib.parse import urlparse

import ubjson

from urpc.src.ffi import *

LOG_LVL = logging.DEBUG
LOG_TAG = 'svc.httpclient'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


class HttpClientSvc:
    def __init__(self, rpc):
        self.rpc = rpc
        self.daemon_id = rpc.daemon_id
        self.rpc.svc_register(rpc.Service("udbd_http_request", self.__udbd_http_request))
        self.rpc.svc_register(rpc.Service("udbd_http_getresponse", self.__udbd_http_getresponse))
        self.rpc.svc_register(rpc.Service("udbd_http_read", self.__udbd_http_read))
        self.rpc.svc_register(rpc.Service("udbd_http_send", self.__udbd_http_send))
        self.rpc.svc_register(rpc.Service("udbd_http_close", self.__udbd_http_close))
        self.socket_tbl = dict()
        self.daemon_socket_startup_time = 0

    def __reset_check(self, input):
        # clean the socket table when daemon first login
        if 'startup_time' not in input:
            return
        if input['startup_time'] != self.daemon_socket_startup_time:
            self.daemon_socket_startup_time = input['startup_time']
            for s in self.socket_tbl:
                try:
                    self.socket_tbl[s]['conn'].close()
                    logger.debug("close the legacy http client %d", s)
                except Exception as e:
                    logger.error("close the legacy http client failed: %s", e)
            self.socket_tbl = dict()
            logger.info("daemon was first connect to udb http client share network, time: %s",
                        time.asctime(time.localtime(input['startup_time'])))

    def __socket_new(self, c):
        retry = 10
        while retry > 0:
            v = random.randint(1, 2147483647)
            if v not in self.socket_tbl:
                self.socket_tbl[v] = c
                return v
            retry = retry - 1
        c['conn'].close()
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

    def __socket_delete(self, v):
        return self.socket_tbl.pop(v)

    def __udbd_http_request(self, input):
        input = ubjson.loadb(input)
        self.__reset_check(input)
        result = -1
        remote_socket = -1
        headers = []
        method = None
        start_time = time.time()
        try:
            p_input = str(input)
            p_url = input['url']
            p_header = input['header']
            p_timeout = input['timeout']
            headers = p_header;
        except Exception as e:
            logger.error("__udbd_http_request parameter error:%s\nerror msg:\n%s", p_input, e)
        else:
            try:
                parsed_uri = urlparse(p_url)
                if parsed_uri.scheme == 'https':
                    import certifi, ssl
                    cafile = certifi.where()
                    ctx = ssl.create_default_context(cafile=cafile)
                    ctx.verify_mode = ssl.CERT_REQUIRED
                    conn = http.client.HTTPSConnection(parsed_uri.hostname, parsed_uri.port, timeout=p_timeout,
                                                       context=ctx)
                    logger.debug("HTTPSConnection(%s, %s, %s)",parsed_uri.hostname, parsed_uri.port, p_timeout)
                else:
                    conn = http.client.HTTPConnection(parsed_uri.hostname, parsed_uri.port, timeout=p_timeout)
                    logger.debug("HTTPConnection(%s, %s, %s)",parsed_uri.hostname, parsed_uri.port, p_timeout)
                # 由于设备端 http client 并不标准，第一个头是请求行信息，所以这里进行一次分割，取出请求行及请求头
                headers = p_header.split('\r\n', 1)
                # 请求行的第一个字符串是请求方法类型
                method = headers[0].split(' ', 1)
                method = method[0]
                # 删除 host 信息，由 python http.client 自动添加
                headers_temp = headers[1].split('\r\n')
                headers = dict()
                for header in list(headers_temp):
                    if len(header) > 0:
                        header = header.split(':', 1)
                        if header[0] != 'Host':
                            headers[header[0]] = header[1]
                # 执行 http 请求
                conn.request(method, p_url, None, headers)
                remote_socket = self.__socket_new({'conn': conn})
                result = 0
            except Exception as e:
                logger.error(traceback.format_exc())
                result = -1
            logger.debug("__udbd_http_request(%s, %s, %s) = %s", method, p_url, headers, result)
            logger.debug("__udbd_http_request socket: %d, exec %s ms", remote_socket,
                         str((time.time() - start_time) * 1000))
        return_result = {"remote_socket": remote_socket, "result": result}
        return ubjson.dumpb(return_result)

    def __udbd_http_getresponse(self, input):
        input = ubjson.loadb(input)
        return_result = {"status": -1}
        try:
            p_input = str(input)
            p_sock = input['socket']
        except Exception as e:
            logger.error("__udbd_http_getresponse parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                client = self.__socket_get(p_sock)
                resp = client['conn'].getresponse()
                client['resp'] = resp

                return_result = {"status": int(resp.status), "header_len": len(str(resp.headers)),
                                 "header": str(resp.headers)}

                if "content-length" in resp.headers: 
                    return_result["content_length"] = int(resp.headers.get("content-length"))
                elif "Transfer-Encoding" in resp.headers and resp.headers.get("Transfer-Encoding") == "chunked":
                    return_result["transfer_encoding"] = "chunked"

                
            except Exception as e:
                logger.error(traceback.format_exc())
                result = -1
            logger.debug("__udbd_http_getresponse(%s) = %s", p_sock, return_result)
        return ubjson.dumpb(return_result)

    def __udbd_http_read(self, input):
        input = ubjson.loadb(input)
        data = bytes()
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_size = input['size']
        except Exception as e:
            logger.error("__udbd_http_read parameter error:%s\nerror msg:\n%s", p_input, e)
            result = -1
        else:
            try:
                client = self.__socket_get(p_sock)
                data = client['resp'].read(p_size)
                result = 0
            except Exception as e:
                logger.error(traceback.format_exc())
                result = -1
            logger.debug("__udbd_http_read(%s, %d) = %d, result: %d", p_sock, p_size, len(data), result)
        return data

    def __udbd_http_send(self, input):
        input = ubjson.loadb(input)
        result = -1
        try:
            p_input = str(input)
            p_sock = input['socket']
            p_data = input['data']
            p_size = input['size']
        except Exception as e:
            logger.error("__udbd_http_send parameter error:%s\nerror msg:\n%s", p_input, e)
        else:
            try:
                client = self.__socket_get(p_sock)
                client['conn'].send(p_data)
                result = p_size
            except Exception as e:
                logger.error(traceback.format_exc())
            logger.debug("__udbd_http_send(%d, %s) = %d", p_sock, p_data, p_size)
        return result.to_bytes(4, byteorder='little', signed=True)

    def __udbd_http_close(self, input):
        input = ubjson.loadb(input)
        result = -1
        try:
            p_input = str(input)
            p_sock = input['socket']
        except Exception as e:
            logger.error("__udbd_http_close parameter error:%s\nerror msg:\n%s", p_input, e)
        else:
            try:
                client = self.__socket_delete(p_sock)
                client['conn'].close()
                result = 0
            except Exception as e:
                logger.error(traceback.format_exc())
            logger.debug("__udbd_http_close(%d) = %d", p_sock, result)
        return result.to_bytes(4, byteorder='little', signed=True)