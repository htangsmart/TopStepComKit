# -*- coding: utf-8 -*-

import json
import global_var
import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.context'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

class Context(object):
    """
    读写上下文类，上下文数据保存在设备端，用于标记升级过程中的各个状态
    """

    def __init__(self, ctx_file='/log/ota_ctx.json'):
        """
        类初始化函数
        """
        # 初始化类成员
        rpc = global_var.get('rpc')
        self.__rpc__ = rpc
        self.dcm_key = ctx_file

    def read(self):
        """
        读取上下文
        """

        ctx = {
            "pool": "SystemStorage",
            "keys": [self.dcm_key]
        }
        # 转换成 json
        ctx_json = json.dumps(ctx)
        # 获取远端升级上下文信息
        try:
            result = self.__rpc__.exec_svc(1, "svc_systemstorage_get", bytearray(ctx_json, encoding="utf8"), need_ack=False,
                                need_rsp=True, timeout=10)
            value = json.loads(result.decode('utf-8'))
            if type(value) == dict:
                return json.loads(value[self.dcm_key])
        except Exception as ex:
            logger.error('ota update context read failed. Exception: %s' % str(ex))
        return {}

    def write(self, key, value):
        """
        写上下文
        """
        ctx = {
            "pool": "SystemStorage",
            "values": {self.dcm_key: json.dumps({key: value})}
        }
        # 转换成 json
        ctx_json = json.dumps(ctx)
        # 读取远端升级上下文信息
        try:
            self.__rpc__.exec_svc(1, "svc_systemstorage_set", bytearray(ctx_json, encoding="utf8"), need_ack=False,
                          need_rsp=True, timeout=10)
        except Exception as e:
            logger.error('ota update write context failed. Exception: %s' % str(e))

    def delete(self):
        """
        删除上下文文件
        """
        ctx = {
            "pool": "SystemStorage",
            "values": {self.dcm_key: json.dumps({})}
        }
        # 转换成 json
        ctx_json = json.dumps(ctx)
        try:
            result = self.__rpc__.exec_svc(1, "svc_systemstorage_set", bytearray(ctx_json, encoding="utf8"), need_ack=False,
                          need_rsp=True, timeout=10)
        except Exception as ex:
            logger.error('ota update clean context failed')
            raise ex
