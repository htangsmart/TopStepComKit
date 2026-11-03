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

import json
import logging

import global_var
from mcf.link.link import MCFLinkLayer
from urpc.services.device import DeviceCmd
from urpc.src.urpc_utils import *
from mcf.link.char_dev import MCFLinkDeviceChar
from wearable import BLE_GATT_DATA_FRAME_SIZE, json_lpc, UDBD_SERVER_VER_NUM
from urpc.server.service_status_manage import ServiceStatusManage

LOG_LVL = logging.INFO
LOG_TAG = 'udb.server.daemon'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

# TODO 目前仅支持一个 daemon
DAEMON_ID = 1


class DaemonCmd:
    def __init__(self, link_layer, rpc, daemon_devices):
        self.rpc = rpc
        self.link_layer = link_layer
        self.daemon_devices = daemon_devices

    def search(self, ini_file_path):
        """
        搜索 udb 链路上所有 daemon
        :param ini_file_path: 串口配置文件路径
        :return: daemon 信息
        """
        damon_info = dict()
        port = "PersimWear Watch"
        MCFLinkDeviceChar(self.link_layer, DAEMON_ID, True, BLE_GATT_DATA_FRAME_SIZE)
        damon_info[DAEMON_ID] = port
        return damon_info


# 通知 daemon 蓝牙链接状态发生改变
def notice_device_status_change(input):
    logger.info("set daemon connect status to %s", input["connect"])
    # 修改蓝牙连接状态
    ServiceStatusManage().set_link_layer_status(input["connect"])
    # 蓝牙断开连接，需要同时修改 wearservice 连接状态
    if not input['connect']:
        ServiceStatusManage().set_wear_service_status(False)
    return json_lpc.gen_success_output_json()


#  提供给第三方应用检测是否有设备链接
def service_daemon_is_connect(input):
    app_server = global_var.get("app_server")
    if app_server:
        result = json_lpc.gen_success_output_json()
        result["connect"] = app_server.daemon_device[DAEMON_ID]["connect"]
    else:
        result = json_lpc.gen_failed_output_json('app_server get failed')
    return bytes(json.dumps(result), encoding='utf8')


# 仅供 server 使用的 daemon init，应用上层连接蓝牙之后，调用该方法
def daemon_init_for_server(input):
    # 当蓝牙连接后会调用该 API ，所以此时 daemon 已连接
    notice_device_status_change({'connect': True})
    global_var.set('connect_status', True)
    rpc = global_var.get("rpc")
    # 执行 link_up 服务，建立 wearserive 链接
    try:
        rpc.exec_link_up()
        daemon_device = DeviceCmd(rpc)
        rpc.zlib = daemon_device.zlib(DAEMON_ID)
        rpc.block_size = int(daemon_device.mtu(DAEMON_ID))
        rpc.version = daemon_device.version(DAEMON_ID)
        
        # 用传入的 mtu 大小，计算每整包数据的大小， 39 为经过测试较稳定的一个数值
        cacl_block_size = input['mtu'] * 39

        if cacl_block_size > rpc.block_size:
            # 计算得到的值大于从设备获取的值，使用从设备获取的值，
            pass
        else:
            rpc.block_size = cacl_block_size

        logger.info(" mtu %d, block_size %d", input['mtu'], rpc.block_size)
        # 修改 wearservice 连接状态
        ServiceStatusManage().set_wear_service_status(True)
    except Exception as e:
        logger.error(e)
        ServiceStatusManage().set_wear_service_status(False)
        return json_lpc.gen_failed_output_json("WearService Connect Failed", 502)
    return json_lpc.gen_success_output_json()

# 仅供 server 使用的，通过新链路，增加新的 daemon
def service_add_daemon(input):
    app_server = global_var.get("app_server")
    if app_server:
        result = json_lpc.gen_success_output_json()
        type = MCFLinkLayer.Device.LinkType.UART
        if input["type"].upper() == 'UART':
            type = MCFLinkLayer.Device.LinkType.UART
        elif input["type"].upper() == 'SOCKET':
            type = MCFLinkLayer.Device.LinkType.SOCKET
        if app_server.add_daemon(type, input) == 0:
            result["values"] = True
        else:
            result["values"] = False
    else:
        result = json_lpc.gen_failed_output_json('app_server get failed')
    return bytes(json.dumps(result), encoding='utf8')
