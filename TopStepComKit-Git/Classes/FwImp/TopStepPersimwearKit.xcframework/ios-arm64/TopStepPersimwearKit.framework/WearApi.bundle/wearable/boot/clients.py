import logging
import socket
import time
import json
import threading
import traceback

import global_var
from mcf.link.link import MCFLinkLayer
from mcf.trans.trans import MCFTransLayer
from mcf.link.socket_tcp import MCFLinkDeviceSocket
from urpc.src.urpc import uRPC
from urpc.services.device import DeviceCmd
from urpc.services.device import DeviceSvc
from wearable import json_lpc

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.clients'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

PUBLIC_ID = 254

client_daemon_device = None
client_rpc = None

# error code
APP_NOT_INSTALLED       = 200
APP_IS_INSTALLED        = 201
APP_NOT_RUNNING         = 202
APP_IS_RUNNING          = 203
APP_SEND_MSG_FAILED     = 204
APP_SEND_MSG_SUCCESS    = 205

global_client_server = None
global_client_name = ''


# 手机 app 本地服务，接收来自手表 app 的消息
def recv_msg(input):
    msg = {"message": str(input, encoding="utf8")}
    input = {'module': "wear.core.message", 'event': 'message.receive', 'msg': msg}
    json_lpc.invoke_callback(input)
    value = APP_SEND_MSG_SUCCESS
    return int.to_bytes(value, length=1, byteorder='big', signed=False)


# 检测手机应用是否运行
def app_ping(input):
    return int.to_bytes(APP_IS_RUNNING, length=1, byteorder='big', signed=False)


# 检测手机应用是否安装
def app_installed(input):
    msg = {"pkg_name": str(input, encoding="utf8")}
    input = {'module': "wear.mobile.appIsInstalled", 'event': 'mobile.app', 'msg': msg}
    result = json_lpc.invoke_callback(input)
    value = APP_IS_INSTALLED if result else APP_NOT_INSTALLED
    return int.to_bytes(value, length=1, byteorder='big', signed=False)


# 断线重连
def reconnect():
    while True:
        connect_result = rpc_init(global_client_name)
        if connect_result is not False:
            return
        time.sleep(3)


def daemon_status_changed(input):
    json_msg = json.loads(str(input, encoding="utf8"))
    msg = {"new_status": json_msg['connect']}
    values = {'module': "device.connection.status", 'event': 'device.connection', 'msg': msg}
    json_lpc.invoke_callback(values)
    if json_msg['connect']:
        # 连接上设备时，需要重新初始化 daemon
        daemon_init_for_client(None)


class ClientService:
    """
    wearable client service
    """

    def __init__(self, rpc):
        global global_client_server
        self.rpc = rpc
        thread = threading.Thread(target=self.heartbeat, daemon=True, name="client_heartbeat")
        thread.start()
        self.connect_status = False
        global_client_server = self

    def login(self, did, client_name):
        """
        client login to server
        :param did: client device id
        :param client_name:  client package name
        :return:
        """
        args = {"client_name": client_name, "did": did}
        args = bytearray(json.dumps(args), encoding="utf8")
        try:
            result = self.rpc.exec_svc(0, "login", args, need_rsp=True, need_ack=False, timeout=10)
        except Exception as e:
            logger.error("overtime")
            return False

        return result

    def logout(self, did):
        """
        client logout to server
        :param did: client device id
        :return:
        """
        args = {"did": did}
        args = bytearray(json.dumps(args), encoding="utf8")
        try:
            result = self.rpc.exec_svc(0, "logout", args, need_rsp=True, need_ack=False, timeout=10)
        except Exception as e:
            logger.error("overtime")
            return False

        return result

    def heartbeat(self):
        device = DeviceSvc(self.rpc)
        default_status = False
        while True:
            try:
                new_status = device.ds_heartbeat()
                self.connect_status = True
            except Exception as e:
                msg = {'newStatus': False}
                self.connect_status = False
                input = {'module': "service.connection.status", 'event': 'connection.status.change', 'msg': msg}
                json_lpc.invoke_callback(input)
                reconnect()
                break
            if new_status != default_status:
                default_status = new_status
                msg = {'newStatus': new_status}
                input = {'module': "service.connection.status", 'event': 'connection.status.change', 'msg': msg}
                json_lpc.invoke_callback(input)
            time.sleep(5)

    def has_device_connected(self):
        try:
            result = self.rpc.exec_svc(0, "service_daemon_is_connect", need_rsp=True, need_ack=False, timeout=10)
            return result
        except Exception as e:
            return json_lpc.gen_failed_output_json(str(e))


def client_rpc_init(serial=None, conn=True, daemon_list=False, client_name=''):
    # client 通过 socket 连接到 server
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_port = 41729
    try:
        client.connect(("localhost", server_port))
    except Exception as e:
        logger.error("client connect server failed")
        # socket 连接失败，但是不能阻止本地 rpc 的初始化
        # return False

    client_port = client.getsockname()[1]

    # client 共用 did: 254， 初始化链路层
    link_layer = MCFLinkLayer()
    # 保存 socket 连接对象
    MCFLinkDeviceSocket(link_layer, client, client_port, PUBLIC_ID)
    # 初始化传输层，需要传入链路层示例对象，供后期发送数据时使用
    trans_layer = MCFTransLayer(link_layer, PUBLIC_ID)
    rpc = uRPC(trans_layer)

    # 执行 login 动作，获取 device id
    daemon_device = DeviceCmd(rpc)
    did = daemon_device.get_id()
    # 获取 did 失败，触发异常
    assert did, "client login failed."

    # 销毁共用设备，注册 client 唯一 ID
    socket_device = link_layer.devices[PUBLIC_ID]
    link_layer.devices_destroy(socket_device)
    link_layer.devices[did] = socket_device
    link_layer.devices[did].pid = did
    rpc.d2d.did = did

    # 执行 login 动作，向 server 注册 client 唯一描述符
    client_service = ClientService(rpc=rpc)
    client_service.login(did=did, client_name=client_name)

    global client_daemon_device
    global client_rpc

    client_daemon_device = daemon_device
    client_rpc = rpc

    daemon = client_daemon_device.list(daemon_list)
    for port, device in daemon.items():
        if not device:
            continue
        logger.debug("mtu block size{}".format(int(daemon[port]['mtu'])))

    if conn:
        return rpc


def has_device_connected(input):
    if global_client_server is not None:
        status = global_client_server.has_device_connected()
        return status
    else:
        result = json_lpc.gen_success_output_json()
        result["values"] = False
        return result


# 仅供 client 使用的 daemon init
def daemon_init_for_client(input):
    result = json_lpc.gen_success_output_json()
    serial = None
    daemon_list = False
    global client_daemon_device
    global client_rpc
    # 获取 daemon 列表
    daemon = client_daemon_device.list(daemon_list)
    if not daemon:
        logger.error("no daemon in the udb link.")
        return result

    # 判断是否指定 daemon
    if serial in list(daemon.keys()) and "active" in daemon[serial]["state"]:
        try:
            client_rpc.daemon_id = daemon[serial]["id"]
            client_rpc.zlib = daemon[serial]["zlib"]
            client_rpc.block_size = int(daemon[serial]["mtu"])
            client_rpc.d2d.translayer.support_ack = daemon[serial]["support_ack"]
            return result
        except Exception as e:
            logger.error(traceback.format_exc())
            return result

    # 获取设备列表中第一个可用设备
    for port, device in daemon.items():
        if not device:
            continue
        if "active" in device["state"]:
            try:
                client_rpc.daemon_id = daemon[port]["id"]
                client_rpc.zlib = daemon[port]["zlib"]
                client_rpc.block_size = int(daemon[port]["mtu"])
                client_rpc.d2d.translayer.support_ack = daemon[port]["support_ack"]
                return result
            except Exception as e:
                logger.error(traceback.format_exc())
                return result
    else:
        logger.error("no devices/emulators found.")
        return result


# 检测 client 与 server 是否连接
def get_server_status(port=41729):
    if global_client_server is not None:
        result = json_lpc.gen_success_output_json()
        result["values"] = global_client_server.connect_status
        return result
    result = json_lpc.gen_success_output_json()
    result["values"] = False
    return result


# client 连接 server
def rpc_init(client_name=''):
    global global_client_name
    global_client_name = client_name
    try:
        # 在 rpc 初始化之前，需要确保蓝牙连接成功，否则 rpc 初始化失败
        rpc = client_rpc_init(client_name=client_name)
        # 注册 client 服务
        if rpc:
            rpc.svc_register(rpc.Service("recv_msg", recv_msg))
            rpc.svc_register(rpc.Service("app_ping", app_ping))
            rpc.svc_register(rpc.Service("app_installed", app_installed))
            rpc.svc_register((rpc.Service("daemon_status_changed", daemon_status_changed)))
        logger.info("uRPC boot successfully {}".format(rpc))
        global_var.set('rpc', rpc)
    except Exception as e:
        logger.error(traceback.format_exc())
        return False
    return rpc


def sport_health_client(input):
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_port = 41729
    rpc = global_var.get('rpc')
    daemon_device = DeviceCmd(rpc)
    did = daemon_device.get_id()
    try:
        client.connect(("localhost", server_port))
        client_service = ClientService(rpc=rpc)
    #        client_service.login(did=did, client_name="sport_health")
    except Exception as e:
        logger.error("client connect server failed {}".format(e))
    output = json_lpc.gen_success_output_json()
    logger.info("server client connect server {}".format(output))
    return output
