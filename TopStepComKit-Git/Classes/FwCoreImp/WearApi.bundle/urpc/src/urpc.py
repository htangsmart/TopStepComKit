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
import logging
import global_var
from .urpc_utils import *
from mcf import mcf
from mcf.trans.d2d import D2DPacket
from .ffi import *
import json
from urpc.server.service_status_manage import ServiceStatusManage
from wearable import UDBD_SERVER_VER_NUM
from utils.observable import FrameObservable

LOG_LVL = logging.DEBUG
LOG_TAG = 'urpc'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

# SDK 内部建立 wearService 连接的 svc 服务名称参数
LINK_UP_SERVICE = Arg(U8 | ARRAY, bytearray('_link_up', encoding="utf8")).to_bytes()

HEARBEAT_SERVICE = Arg(U8 | ARRAY, bytearray('_ping', encoding="utf8")).to_bytes() + Arg(U8, 0xFF).to_bytes()

DEV_INFO_SERVICE = Arg(U8 | ARRAY, bytearray('_dev_info', encoding="utf8")).to_bytes()


def bytearray_startswith(arr, prefix):
    if len(arr) < len(prefix):
        return False

    for i in range(len(prefix)):
        if arr[i] != prefix[i]:
            return False
    return True

class uRPC:
    def __init__(self, translayer):
        self.is_executing = False
        self.svc_map = {}
        self.daemon_id = 1
        self.block_size = 512
        self.zlib = False
        self.version = "0.0.0"
        self.d2d = translayer.get_proto(mcf.ProtoType.D2D)
        self.d2d.set_req_fun(self.__exec_local_svc)
        logger.debug("uRPC initialize success")

    class Service:
        def __init__(self, name, fun, ver=1):
            self.name = name
            self.fun = fun
            self.ver = ver

    def svc_register(self, svc):
        key = svc.name + "@" + str(svc.ver)
        if key not in self.svc_map:
            self.svc_map[key] = svc
        else:
            logger.warning("Service (%s) already register", svc.name)

    def __gen_pkt(self, name, ver, input):
        payload = bytearray()
        payload += bytearray(name, encoding="utf8")
        payload.append(0)  # '/0'
        payload.append(ver)
        payload += bytearray(input)
        return payload
    
    def exec_link_up(self):
        # 通知 daemon 执行 link up
        self.exec_ffi_func(self.daemon_id, "_link_up", need_ack=False, need_rsp=True, timeout=2, retry=1)
        args = {"version": UDBD_SERVER_VER_NUM}
        args = bytearray(json.dumps(args), encoding="utf8")
        self.exec_svc(self.daemon_id, "_link_up2", args, need_ack=False, need_rsp=True, timeout=3)

    def exec_svc(self, dst_id, name, input=bytearray(), need_ack=False, need_rsp=False, timeout=10, ver=1, retry = 5):
        logger.debug("exec a RPC service, name: %s, dst_id: %d", name, dst_id)
        payload = self.__gen_pkt(name, ver, input)
        # 发送 D2D 报文
        send_pkt = self.d2d.pkt_gen(dst_id, D2DPacket.Type.REQ, need_ack, need_rsp, 0, payload)
        while retry >= 0:
            connect_status = ServiceStatusManage().get_wear_service_status()
            # 未建立连接并且不是 _link_up / _ping  / _dev_info 服务，抛出错误
            if not connect_status and not bytearray_startswith(input, LINK_UP_SERVICE)\
                    and name is not "_link_up2" and not bytearray_startswith(input, HEARBEAT_SERVICE)\
                    and not bytearray_startswith(input, DEV_INFO_SERVICE):
                raise UrpcDisconnectException()
            self.d2d.send(send_pkt, non_block=True)
            if need_rsp:
                recv_pkt = self.d2d.recv(send_pkt, timeout)
                if recv_pkt is not None:
                    if len(recv_pkt.payload) == 0 and name != 'ffi':
                        logger.error("svc (%s) not found", name)
                        raise UrpcSvcNotFoundException()
                    # TODO 发出超时或其他错误异常
                    return recv_pkt.payload
                elif retry == 0:
                    if not bytearray_startswith(input, HEARBEAT_SERVICE):
                        # 链路检测服务超时不需要进行通知
                        FrameObservable().notify_observers(408)
                    raise UrpcTimeoutException()
                retry -= 1
            else:
                break
    


    def exec_ffi_func(self, dst_id, func_name, args=[], need_ack=False, need_rsp=False, timeout=10, ver=1, retry = 5):
        logger.debug("exec a FFI RPC service, func_name: %s, dst_id: %d", func_name, dst_id)
        input = bytearray()
        args = [Arg(U8 | ARRAY, bytearray(func_name, encoding="utf8"))] + args
        for arg in args:
            assert isinstance(arg, Arg)
            input += arg.to_bytes()
        try:
            output = self.exec_svc(dst_id, "ffi", input, need_ack, need_rsp, timeout, ver, retry)
        except UrpcDisconnectException as e:
            raise UrpcDisconnectException()
        except Exception as e:
            raise UrpcTimeoutException()
        if need_rsp and output is not None and len(output) > 0:
            results = []
            # 获取全部返回值
            while True:
                result = Arg()
                result.from_bytes(output)
                results.append(result)
                if result.len < len(output):
                    output = output[result.len:]
                else:
                    break
            # 获取函数返回值，目前每次 ffi 函数请求后，均会有返回值，除非函数未找到
            # 原始函数如果返回为空，ffi 函数也会返回 uint32_t 的 0
            ret = results.pop(0)
            # 获取入参中的值返回
            for arg in args:
                if arg.type & EDITABLE == EDITABLE:
                    edited_arg = results.pop(0)
                    arg.value = edited_arg.value
                    arg.value_len = edited_arg.value_len
                    arg.len = edited_arg.len
            # 返回函数返回值
            return ret
        elif output is not None and len(output) == 0:
            logger.error("ffi function (%s) not found", func_name)
            raise UrpcSvcNotFoundException()

    def __exec_local_svc(self, pkt):
        _0_index = pkt.find(0)
        svc_name = pkt[:_0_index].decode('utf-8')
        svc_ver = pkt[_0_index + 1]
        svc_key = svc_name + "@" + str(svc_ver)
        logger.info("exec local svc %s@V%s", svc_name, str(svc_ver))
        if svc_key in self.svc_map:
            output = self.svc_map[svc_key].fun(pkt[_0_index + 2:])
            return output
        else:
            return bytearray("service not found", encoding="utf8")

    def compare_version(self, version):
        """
        传入不带英文的版本号,特殊:"10.12.2.6.5">"10.12.2.6"
        :list1  = self.version 当前版本号
        :list2  = version 输入版本号
        :return: version >  self.version 返回 -1
                 version == self.version 返回 0
                 version < self.version  返回 1
        """
        logger.info("current verion: %s, compare version: %s", self.version, version)
        list1 = str(self.version).split(".")
        list2 = str(version).split(".")
        # 循环次数为短的列表的len
        for i in range(len(list1)) if len(list1) < len(list2) else range(len(list2)):
            if int(list1[i]) == int(list2[i]):
                pass
            elif int(list1[i]) < int(list2[i]):
                return -1
            else:
                return 1
        # 循环结束，哪个列表长哪个版本号高
        if len(list1) == len(list2):
            return 0
        elif len(list1) < len(list2):
            return -1
        else:
            return 1
