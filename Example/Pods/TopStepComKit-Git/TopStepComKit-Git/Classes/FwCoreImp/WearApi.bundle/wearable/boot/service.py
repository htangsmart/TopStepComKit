try:
    import traceback
    import logging
    import socket
    import json
    import random
    import socket
    import threading
    import time
    import ubjson
    import base64
    import copy

    LOG_LVL = logging.INFO
    LOG_TAG = 'wearable.service'
    logger = logging.getLogger(LOG_TAG)
    logger.setLevel(LOG_LVL)

    import global_var
    from mcf.link.char_dev import MCFLinkDeviceChar
    from mcf.link.link import MCFLinkLayer
    from mcf.link.socket_tcp import MCFLinkDeviceSocket
    from mcf.mcf import MCF_PKT_MAX_SIZE
    from mcf.trans.trans import MCFTransLayer
    from urpc.server.daemon import DaemonCmd, DAEMON_ID, daemon_init_for_server, service_add_daemon
    from urpc.services.httpclient import HttpClientSvc
    from urpc.services.sal import SalSvc
    from urpc.src.ffi import *
    from urpc.src.urpc import uRPC
    from wearable import json_lpc, BLE_GATT_DATA_FRAME_SIZE
    from wearable.boot.common import register_lpc_svc
    from urpc.server.daemon import notice_device_status_change, service_daemon_is_connect
    from urpc.server.service_status_manage import ServiceStatusManage
    from utils.observable import Observer, FrameObservable
    from wearable.py_patch.py_patch import exec_py_patch
except Exception as e:
    logger.info(traceback.format_exc())



PUBLIC_ID = 254

# error code
APP_NOT_INSTALLED = 200
APP_IS_INSTALLED = 201
APP_NOT_RUNNING = 202
APP_IS_RUNNING = 203
APP_SEND_MSG_FAILED = 204
APP_SEND_MSG_SUCCESS = 205
APP_LAUNCH_FAILED = 206
APP_LAUNCH_SUCCESS = 207
APP_DATA_CHANNEL_FAILED = 208
APP_DATA_CHANNEL_SUCCESS = 209

SERVER_APP_NAME= ''


class AppServer(MCFLinkLayer.Device):
    """
    运动健康 app Server
    """

    def __init__(self, link_layer, run_app_name):
        self.link_layer = ''
        self.apps_info = dict()
        self.data_info = dict()
        self.rpc = None
        self.run_app_name = run_app_name
        self.daemon_device = dict()
        # TODO: 目前 daemon 设备固定 did 为 1
        self.did = 1
        self.server = None
        self.recv_msg_lock = threading.Lock()
        
        self.link_layer = link_layer
        self.has_device = False
        # 字符设备对象
        self.device_char = None

        self.__daemon_socket = None
        device = super().__init__(0, self.LinkType.SOCKET, True, MCF_PKT_MAX_SIZE,
                                  self.__socket_send, self.__socket_recv)

        link_layer.device_register(device)

        self.device_service_check_thread()

        # 添加运动健康信息
        health_app = dict()
        health_app['did'] = 0
        health_app['msg'] = list()
        health_app['timestamp'] = 0
        health_app['index'] = 0
        self.apps_info[run_app_name] = health_app
        # 初始化 data_info
        self.data_info['timestamp'] = 0
        self.data_info['msg'] = bytes()
        self.data_info['index'] = 0

        logger.info('WearCore Server start finish')

    def login(self, input):
        """
        client 主动执行 login 动作，server 保存 client 描述信息
        :param args:
        :return:
        """
        args = json.loads(str(input, encoding='utf-8'))
        client_name = args['client_name']
        did = int(args['did'])
        # 判断 client id 是否存在于 devices
        if did not in self.link_layer.devices.keys():
            if client_name in self.apps_info.keys():
                del self.apps_info[client_name]
            return bytearray("False", encoding="utf8")

        logger.debug("pkg_name: {}, did: {} login success".format(client_name, did))
        # 注册 pkg_name
        app_dict = dict()
        app_dict['did'] = did
        app_dict['msg'] = list()
        app_dict['timestamp'] = 0
        app_dict['index'] = 0
        self.apps_info[client_name] = app_dict

        return bytearray("True", encoding="utf8")

    def logout(self, input):
        """
        client 主动执行 logout 动作，server 删除 client 描述信息。
        :param args:
        :return:
        """
        args = json.loads(str(input, encoding='utf-8'))
        client_name = args["client_name"]
        did = int(args['did'])
        # 判断 client id 是否存在于 devices
        if did not in self.link_layer.devices.keys():
            if client_name in self.apps_info.keys():
                del self.apps_info[client_name]
            return bytearray("False", encoding="utf8")

        logger.debug("pkg_name: {}, did: {} logout success".format(client_name, did))

        del self.apps_info[client_name]
        self.link_layer.devices_destroy(self.link_layer.devices[did])

        return bytearray("True", encoding="utf8")

    @staticmethod
    def heartbeat(input):
        """
        client 与 server 心跳服务。
        """
        return int.to_bytes(1, length=1, byteorder='big', signed=False)

    @staticmethod
    def __socket_recv():
        payload = bytearray()
        return payload

    @staticmethod
    def __socket_send(pkt, timeout=None):
        pass

    def scan_daemon(self):
        """
        server 扫描 daemon 信息。
        """
        if not self.rpc:
            return
        device = DaemonCmd(link_layer=self.link_layer, rpc=self.rpc, daemon_devices=self.daemon_device)
        serial = device.search(None)
        for did, port in serial.items():
            daemon = dict()
            if not did:
                continue
            daemon["support_ack"] = self.link_layer.devices[int(did)].support_ack
            daemon["port"] = port
            daemon["connect"] = False
            self.daemon_device[did] = daemon

    def add_daemon(self, type, input):
        """
        添加新的 daemon ，PS：目前系统只支持一个 daemon
        :param type: 新 daemon 所使用的链路类型 LinkType(Enum)
        :param args: 新链路相关的参数
        :return : 连接新 daemon 的结果， 0: 成功
        """
        args = input['args']
        mtu = input['mtu']

        daemon = dict()
        # 断开以前的 socket 链接
        if self.__daemon_socket:
            try:
                self.__daemon_socket.shutdown(socket.SHUT_RDWR)
                self.__daemon_socket.close()
            except Exception as e:
                pass
            self.__daemon_socket = None

        if type == MCFLinkLayer.Device.LinkType.SOCKET:
            # daemon 通过 socket 连接到 server ，默认 7758 端口
            conn_port = 7758
            try:
                ip, conn_port = args.split(':', 1)
                self.__daemon_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.__daemon_socket.connect((ip, int(conn_port)))
                logger.info("daemon connect success")
                MCFLinkDeviceSocket(self.link_layer, self.__daemon_socket, conn_port, DAEMON_ID)
                # 连接上设备时，需要重新初始化 daemon
                daemon_init_for_server(None)
                daemon["connect"] = True
            except Exception as e:
                daemon["connect"] = False
                logger.error("%s, daemon %s connect FAILED", e, args)
        elif type == MCFLinkLayer.Device.LinkType.UART:
            daemon["connect"] = False
            # mtu 的大小减去 5 作为每帧数据的长度，避免出现位置问题
            self.device_char = MCFLinkDeviceChar(self.link_layer, DAEMON_ID, True, mtu - 5)

        if daemon["connect"]:
            daemon["support_ack"] = self.link_layer.devices[int(DAEMON_ID)].support_ack
            daemon["port"] = "PersimWear Watch"
            self.daemon_device[DAEMON_ID] = daemon
            return 0
        else:
            return -1

    def device_service_check_thread(self):
        """
        检查链路状态定时器，链路已连接时，24 小时检测一次（约等于无），链路异常时，3s 检测一次
        """
        default_interval = 1 * 60 * 60 * 24

        service_check_interval = default_interval


        last_session_uuid = None

        def _service_check_helper():
            daemon_connect_status = None
            ping = Arg(U8, 0xFF)
            nonlocal last_session_uuid
            if ServiceStatusManage().get_link_layer_status():
                # 蓝牙已连接 
                for daemon in list(self.daemon_device.keys()):
                    try:
                        logger.info("\n\nstart link check\n\n")
                        last_session_uuid = ServiceStatusManage().get_session_uuid()
                        self.rpc.exec_ffi_func(int(daemon), "_ping", [ping], need_ack=False,
                                            need_rsp=True, timeout=2, retry = 0)
                    except Exception as e:
                        cur_session_uuid = ServiceStatusManage().get_session_uuid()

                        if last_session_uuid == cur_session_uuid:
                            logger.error("daemon: {} service status check overtime.".format(self.daemon_device[daemon]["port"]))
                            # 标记 daemon 为离线状态
                            self.daemon_device[daemon]["connect"] = False
                            self.has_device = False
                            # 检测超时，重启定时器
                            FrameObservable().notify_observers(408)
                        
                            ServiceStatusManage().set_wear_service_status(False)
                            if daemon_connect_status is None or daemon_connect_status is True:
                                daemon_connect_status = False
                                self.notice_client_daemon_changed({'connect': False})

                    else:
                        # 连接上设备时通知 client 重新初始化 daemon 信息
                        self.has_device = True
                        ServiceStatusManage().set_wear_service_status(True)
                        if not daemon_connect_status is True:
                            # 检测到的状态从断开到连接，通知降低检测频率
                            FrameObservable().notify_observers(200)
                            daemon_connect_status = True
                            self.notice_client_daemon_changed({'connect': True})

                        # 标记 daemon 为在线状态
                        self.daemon_device[daemon]["connect"] = True
            else:
                logger.debug("service check skip because link layer status %d", ServiceStatusManage().get_link_layer_status())

        
        service_check_timer = None

        class ServiceCheckTimerObserver(Observer):
            def update(self, data):
                nonlocal service_check_timer
                nonlocal service_check_interval
                if data == 200:
                    # 链路已经连上，检测间隔修改成为 24 小时
                    service_check_interval = default_interval
                elif data == 480:
                    # 某个服务执行超时，进行链路检测
                    service_check_interval = 1 * 3
                elif data == -1:
                    # 接收到数据帧时，需要重启定时器
                    if ServiceStatusManage().get_wear_service_status():
                        # 如果内部状态为已连接，不进行链路检测，检测间隔修改成为 24 小时
                        service_check_interval = default_interval
                    else:
                        # 否则 3s 后检测链路
                        service_check_interval = 1 * 3
                else:
                    service_check_interval = 1 * 3

                if service_check_timer:
                    logger.debug("cancel last timer")
                    service_check_timer.cancel()
                logger.debug("start a new timer service_check_interval is %d", service_check_interval)
                service_check_timer = threading.Timer(service_check_interval, _service_check_helper)
                service_check_timer.start()

        service_check_timer_observer = ServiceCheckTimerObserver()
        
        FrameObservable().add_observer(service_check_timer_observer)

    # daemon 连接状态发生变化时，通知所有的 client
    def notice_client_daemon_changed(self, input):
        for client_name in self.apps_info.keys():
            client_did = self.apps_info[client_name]["did"]
            try:
                self.rpc.exec_svc(client_did, "daemon_status_changed",
                                bytearray(json.dumps(input), encoding="utf8"), need_ack=False,
                                need_rsp=False, timeout=3)
            except Exception as e:
                pass

    def find_app(self, app_name):
        try:
            if app_name not in self.apps_info.keys():
                logger.warning("app: {} not found".format(app_name))
                return False, False
            app_did = self.apps_info[app_name]["did"]
            if app_did not in self.link_layer.devices.keys():
                logger.error("app: {} link disconnect".format(app_name))
                del self.apps_info[app_name]
                return False, False
        except Exception as e:
            logger.error(e)
            return False, False

        return app_name, app_did

    @staticmethod
    def gen_result(code):
        return int.to_bytes(code, length=1, byteorder='big', signed=False)

    def msg_send(self, args):
        """
        server 收到来自手表 app 消息，根据描述信息，转发到对应的手机 app
        msg 格式定义如下：
        "app": app name,
        "msg": "hello, world",
        "total": 10240 使用真实的长度
        "timestamp": 当前 msg 时间戳
        "index": 已传输长度
        """
        try:
            logger.info("args: {}".format(args))
            input = json.loads(str(args, encoding='utf-8', errors='ignore'))
            logger.info("input: {}".format(input))
        except Exception as e:
            logger.info(e)
            return self.gen_result(APP_SEND_MSG_FAILED)

        input_body = input['body']
        if input_body['tag'] == 'ping':
            print(input_body['content'])
            return self.app_ping(input_body['content'])
        elif input_body['tag'] == 'appIsInstalled':
            return self.app_installed(input_body['content'])
        elif input_body['tag'] == 'launchMobileApp':
            return self.app_launch(input_body['content'])
        elif input_body['tag'] == 'message':
            return self.forward_message(input_body['content'])
        elif input_body['tag'] == 'noticeLocation':
            return self.notice_location(input_body['content'])

    def msg_send_ubjson(self, args):
        """
        server 收到来自手表 app 消息，根据描述信息，转发到对应的手机 app
        msg 格式定义如下：
        "app": app name,
        "msg": "hello, world",
        "total": 10240 使用真实的长度
        "timestamp": 当前 msg 时间戳
        "index": 已传输长度
        """
        with self.recv_msg_lock:
            try:
                logger.info("input_ubj: {}".format(args))
                input_obj = ubjson.loadb(args)
                logger.info("input_obj: {}".format(input_obj))
            except Exception as e:
                logger.info(e)
                return self.gen_result(APP_SEND_MSG_FAILED)

            input_body = input_obj['body']
            input = input_body['content']
            # 判断是否为首次传输，如果为首次传输，初始化对应的参数
            if self.data_info['timestamp'] != input['timestamp']:
                self.data_info['timestamp'] = input['timestamp']
                self.data_info['msg'] = bytes()
                self.data_info['index'] = 0
            # 未接收完成
            if len(self.data_info['msg']) < input['total']:
                self.data_info['msg'] = self.data_info['msg'] + input['msg']
                self.data_info['index'] = input['index']
                logger.info("msg_send_ubjson msg_total:{}, msg_index:{} , cur_index:{}".format(input['total'], input['index'], self.data_info['index']))
            # 已接收完成
            if self.data_info['index'] == input['total']:
                # 解析接收到的数据, 替换原数据中的 msg 对象
                message = ubjson.loadb(self.data_info['msg'])
                input_body['content']['msg'] = copy.deepcopy(message)
                # 清空接收数据缓冲区
                self.data_info['msg'] = bytes()
                # 分发数据包
                if input_body['tag'] == 'ping':
                    return self.app_ping(input_body['content'])
                elif input_body['tag'] == 'appIsInstalled':
                    return self.app_installed(input_body['content'])
                elif input_body['tag'] == 'launchMobileApp':
                    return self.app_launch(input_body['content'])
                elif input_body['tag'] == 'message':
                    return self.forward_message_ubjson(input_body['content'])
                elif input_body['tag'] == 'noticeLocation':
                    return self.notice_location(input_body['content'])
                elif input_body['tag'] == 'dataChannel':
                    return self.data_channel_ubjson(input_body['content'])
            # 接收出现错误
            elif self.data_info['index'] > input['total']:
                logger.error("data_channel receive failed.")
                logger.error("msg_send_ubjson msg_total:{}, msg_index:{} , cur_index:{}".format(input['total'], input['index'], self.data_info['index']))
                self.data_info['msg'] = bytes()
                # 返回接收失败
                return self.gen_result(APP_SEND_MSG_FAILED)
            else:
                return self.gen_result(APP_SEND_MSG_FAILED)

    # 数据通道
    def data_channel_ubjson(self, input):
        try:
            channel = input['msg']['channel']
            buffer = input['msg']['buffer']
            # 输入的字节数组转为base64编码的字符串

            buffer_string = base64.b64encode(buffer).decode('UTF-8')

            # 构造接收数据对象
            msg = {'code': 200, 'msg': 'success', 'values': { "channel": channel, 'buffer': buffer_string }}
            input = {'module': "wear.core.channel", 'event': 'message.receive', 'msg': msg}
            # 回调监听对象
            json_lpc.invoke_callback(input)
            # 返回接收成功
            return self.gen_result(APP_DATA_CHANNEL_SUCCESS)
        except Exception as e:
            logger.info(e)
            return self.gen_result(APP_DATA_CHANNEL_FAILED)

    # 消息分发
    def forward_message_ubjson(self, input):
        """
        server 收到来自手表 app 消息，根据描述信息，转发到对应的手机 app
        msg 格式定义如下：
        "app": app name,
        "msg": "hello, world",
        "total": 10240 使用真实的长度
        "timestamp": 当前 msg 时间戳
        "index": 已传输长度
        """
        try:
            app_name, app_did = self.find_app(input['app'])
            if not app_name or not app_did:
                # 判断是否为发送给运动健康 app 消息
                if input['app'] == "local.control":
                    app_name = SERVER_APP_NAME
                    app_did = 0
                else:
                    return self.gen_result(APP_SEND_MSG_FAILED)
        except Exception as e:
            logger.error(e)
            return self.gen_result(APP_SEND_MSG_FAILED)
        try:
            self.apps_info[app_name]['timestamp'] = input['timestamp']
            self.apps_info[app_name]['msg'] = input['msg']
            self.apps_info[app_name]['index'] = input['index']
            if app_did == 0:
                # 发送给运动健康的消息
                msg = {'code': 200, 'msg': 'success', 'values': { "message": self.apps_info[app_name]['msg'] }}
                input = {'module': "wear.core.message", 'event': 'message.receive', 'msg': msg}
                json_lpc.invoke_callback(input)
                return self.gen_result(APP_SEND_MSG_SUCCESS)
            # 数据接收完后，转发到手机 app
            msg = bytearray(json.dumps(json.loads(self.apps_info[app_name]['msg'])), encoding="utf-8")
            output = self.rpc.exec_svc(app_did, "recv_msg", msg, need_ack=False, need_rsp=True, timeout=3)
            logger.debug("cellphone msg: {}".format(output))
            self.apps_info[app_name]['msg'] = list()
            return output
        except Exception as e:
            logger.error(traceback.format_exc())
            return self.gen_result(APP_SEND_MSG_FAILED)

    # 消息分发
    def forward_message(self, input):
        """
        server 收到来自手表 app 消息，根据描述信息，转发到对应的手机 app
        msg 格式定义如下：
        "app": app name,
        "msg": "hello, world",
        "total": 10240 使用真实的长度
        "timestamp": 当前 msg 时间戳
        "index": 已传输长度
        """
        try:
            app_name, app_did = self.find_app(input['app'])
            if not app_name or not app_did:
                # 判断是否为发送给运动健康 app 消息
                if input['app'] == "local.control":
                    app_name = SERVER_APP_NAME
                    app_did = 0
                else:
                    return self.gen_result(APP_SEND_MSG_FAILED)
        except Exception as e:
            logger.error(e)
            return self.gen_result(APP_SEND_MSG_FAILED)
        try:
            if self.apps_info[app_name]['timestamp'] != input['timestamp']:
                self.apps_info[app_name]['timestamp'] = input['timestamp']
                self.apps_info[app_name]['msg'] = list()
                self.apps_info[app_name]['index'] = 0
            msg_list = list(input['msg'])
            if len(self.apps_info[app_name]['msg']) < input['total']:
                self.apps_info[app_name]['msg'] += msg_list

                self.apps_info[app_name]['index'] = input['index']
                logger.debug("total len: {}, index: {} , app->index: {}".format(input['total'], input['index'],
                                                                            self.apps_info[app_name]['index']))
            if self.apps_info[app_name]['index'] == input['total']:
                self.apps_info[app_name]['msg'] = ''.join(self.apps_info[app_name]['msg'])
                if app_did == 0:
                    # 发送给运动健康的消息
                    msg = {'code': 200, 'msg': 'success', 'values': { "message": self.apps_info[app_name]['msg'] }}
                    input = {'module': "wear.core.message", 'event': 'message.receive', 'msg': msg}
                    json_lpc.invoke_callback(input)
                    return self.gen_result(APP_SEND_MSG_SUCCESS)
                # 数据接收完后，转发到手机 app
                msg = bytearray(json.dumps(json.loads(self.apps_info[app_name]['msg'])), encoding="utf-8")
                output = self.rpc.exec_svc(app_did, "recv_msg", msg, need_ack=False, need_rsp=True,
                                        timeout=3)
                logger.debug("cellphone msg: {}".format(output))
                self.apps_info[app_name]['msg'] = list()
                return output
            elif self.apps_info[app_name]['index'] > input['total']:
                # 数据接收出错
                logger.error("app=>msg {}, app=>index {}, app=>msg_len {}, input total {}, input index {}".format(self.apps_info[app_name]['msg'], self.apps_info[app_name]['index'],
                                len(self.apps_info[app_name]['msg']), input['total'], input['index']))
                logger.error("msg recv failed")
                self.apps_info[app_name]['msg'] = list()
                return self.gen_result(APP_SEND_MSG_FAILED)
            else:
                return self.gen_result(APP_SEND_MSG_SUCCESS)
        except Exception as e:
            logger.error(traceback.format_exc())
            return self.gen_result(APP_SEND_MSG_FAILED)

    def app_ping(self, input):
        """
        send ping cmd to cellphone app, check cellphone app is running.
        :arg: {app: the app name of cellphone}
        """
        try:
            app_name, app_did = self.find_app(input['app'])
            if not app_name:
                return self.gen_result(APP_NOT_RUNNING)
        except Exception as e:
            logger.error(e)
            return self.gen_result(APP_NOT_RUNNING)

        try:
            output = self.rpc.exec_svc(app_did, "app_ping", need_ack=False,
                                       need_rsp=True, timeout=10)
        except Exception as e:
            logger.error(e)
            return self.gen_result(APP_NOT_RUNNING)

        logger.debug("output: {}".format(output))
        return output

    def app_installed(self, input):
        """
        send installed cmd to cellphone app, check cellphone app is installed.
        :arg: {app: the app name of cellphone}
        """

        msg = { 'code': 200, 'msg': 'success', 'values': {"pkg_name": str(bytearray(input['app'], encoding="utf8"), encoding="utf8")}}
        input = {'module': "wear.mobile.appIsInstalled", 'event': 'mobile.app', 'msg': msg}
        result = json_lpc.invoke_callback(input)
        value = APP_IS_INSTALLED if result else APP_NOT_INSTALLED
        return int.to_bytes(value, length=1, byteorder='big', signed=False)

    def app_launch(self, input):
        """
        send launch cmd to cellphone app, to launch mobile application.
        :arg: {app: the app name of cellphone}
        """
        msg = { 'code': 200, 'msg': 'success', 'values': {"pkg_name": str(bytearray(input['app'], encoding="utf8"), encoding="utf8")}}
        input = {'module': "wear.mobile.launchApp", 'event': 'mobile.app', 'msg': msg}
        result = json_lpc.invoke_callback(input)
        value = APP_LAUNCH_SUCCESS if result else APP_LAUNCH_FAILED
        return int.to_bytes(value, length=1, byteorder='big', signed=False)

    # 开启或结束定位
    def notice_location(self, input):
        try:
            msg = { 'code': 200, 'msg': 'success', 'values': {'app': input['app'], 'type': json.loads(input['msg'])['type']}}
        except Exception as e:
            logger.error("notice location error {}".format(e.__str__()))
            return int.to_bytes(0, length=1, byteorder='big', signed=False)
        input = {'module': "wear.location.sync", 'event': 'mobile.app', 'msg': msg}
        result = json_lpc.invoke_callback(input)
        return int.to_bytes(result, length=1, byteorder='big', signed=False)

    def devices(self, args):
        """
        client 获取 daemon 列表
        """
        try:
            pkt = bytearray(json.dumps(self.daemon_device), encoding="utf8")
            logger.debug(pkt)
        except Exception as e:
            logger.error(e)
            pkt = bytearray(1)

        return pkt

    def distribute_id(self, args):
        """
        服务端分发 device ID
        :return: device id
        """
        logger.debug("distribute id: {}".format(self.did))
        pkt = int.to_bytes(self.did, length=1, byteorder='big', signed=False)

        return pkt

    def has_device_connected(self):
        return self.has_device

    def start_share_server(self):
        port = 41729

        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind(('0.0.0.0', port))
        self.server.listen(5)

        def __listen_port():
            while True:
                try:
                    # 等待 client 连接
                    conn, addr = self.server.accept()
                    client_port = conn.getpeername()[1]
                    logger.info("waiting client connect")
                    while True:
                        # 生成 client did  64 <= did <= 128
                        if len(list(self.link_layer.devices.keys())[64:128]) >= 64:
                            logger.error("Server no assigned ID to the client")
                            self.server.shutdown(2)
                            self.server.close()
                            return

                        self.did = random.randint(64, 128)
                        if self.did not in self.link_layer.devices.keys():
                            break

                    MCFLinkDeviceSocket(self.link_layer, conn, client_port, self.did)
                    logger.debug("device: {}".format(self.link_layer.devices))
                except Exception as e:
                    logger.info("server closed")
                    return
        
        server_thread = threading.Thread(target=__listen_port, daemon=True,
                                     name="develop_mode_thread")
        server_thread.start()
        print("* daemon not running; starting now at tcp:{} *".format(port))

    def stop_share_server(self):
        try:
            if not self.server is None:
                self.server.shutdown(2)
                self.server.close()
                self.server = None
        except Exception as e:
            print(e)

def start_develop_mode(input):
    app_server = global_var.get("app_server")
    app_server.stop_share_server()
    app_server.start_share_server()
    return json_lpc.gen_success_output_json()

def stop_develop_mode(input):
    app_server = global_var.get("app_server")
    app_server.stop_share_server()
    return json_lpc.gen_success_output_json()

def sdk_server_start(run_app_name=''):
    try:
        logger.info("service app name: {}".format(run_app_name))
        link_layer = MCFLinkLayer()
        app_server = AppServer(link_layer, run_app_name)
        global_var.set("app_server", app_server)
        trans_layer = MCFTransLayer(link_layer, 0)
        rpc = uRPC(trans_layer)
        # 注册 server 本地服务
        rpc.svc_register(rpc.Service('service_daemon_is_connect', service_daemon_is_connect))
        rpc.svc_register(rpc.Service("devices", app_server.devices))
        rpc.svc_register(rpc.Service("distribute_id", app_server.distribute_id))
        rpc.svc_register(rpc.Service("login", app_server.login))
        rpc.svc_register(rpc.Service("logout", app_server.logout))
        rpc.svc_register(rpc.Service("msg_send", app_server.msg_send))
        rpc.svc_register(rpc.Service("msg_send_ubjson", app_server.msg_send_ubjson))
        rpc.svc_register(rpc.Service("app_ping", app_server.app_ping))
        rpc.svc_register(rpc.Service("app_installed", app_server.app_installed))
        rpc.svc_register(rpc.Service("heartbeat", app_server.heartbeat))
        rpc.svc_register(rpc.Service("exec_py_patch", exec_py_patch))
        # 注册 SAL 本地服务
        SalSvc(rpc)
        # 注册 HTTP client 本地服务
        HttpClientSvc(rpc)
        global_var.set('rpc', rpc)

        def update_mtu(input):
            if app_server.device_char is not None:
                mtu = input['mtu']
                if mtu * 39 < rpc.block_size:
                    rpc.block_size = mtu * 39
                app_server.device_char.update_mtu(mtu)
                return json_lpc.gen_success_output_json()
            return json_lpc.gen_failed_output_json("Device not initialized")
        register_lpc_svc()
        # 初始化 server 特有的 LPC 服务
        # json_lpc.register_svc(daemon_init_for_server)
        json_lpc.register_svc(notice_device_status_change)
        json_lpc.register_svc(service_add_daemon)
        json_lpc.register_svc(start_develop_mode)
        json_lpc.register_svc(stop_develop_mode)
        json_lpc.register_svc(daemon_connected)
        json_lpc.register_svc(update_mtu)
        
        # 启动 server 线程
        input = {'module':  "wear.init", 'event': 'success', 'msg': {'code': 200, 'msg': 'success', 'values': ''}}
        json_lpc.invoke_callback(input)
        app_server.rpc = rpc
        app_server.scan_daemon()

    except Exception as e:
        input = {'module': "wear.init", 'event': 'failed', 'msg': {'code': 500, 'msg': e.__str__(), 'values': ''}}
        json_lpc.invoke_callback(input)

# 通知 SDK 蓝牙连接成功是调用该服务
def daemon_connected(input):
    service_add_daemon(input)
    return daemon_init_for_server(input)



# 启动 server
def server_start(run_app_name=''):
    global SERVER_APP_NAME
    SERVER_APP_NAME = run_app_name
    logger.info("* daemon ==================== *")
    server_port = 41729
    sdk_server_start(run_app_name)
    print("* daemon started successfully *")

