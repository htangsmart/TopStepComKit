# -*- coding: utf-8 -*-

import traceback
import os
import json
import global_var
from wearable.ota import load

import logging

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.ota.utils'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


def ota_compare_version(v1, v2):
    """
    传入不带英文的版本号,特殊:"10.12.2.6.5">"10.12.2.6"
    :list1  = v1 版本号1
    :list2  = v2 版本号2
    :return: v1 >  v2 返回  1
             v1 == v1 返回  0
             v1 <  v2 返回 -1
    """
    list1 = str(v1).split(".")
    list2 = str(v2).split(".")
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


# 升级文件是否要求重启
def ota_get_package_require_reboot(package):
    try:
        # 检查资源包路径是否合法
        if not os.path.isfile(package):
            raise Exception('Is not a valid file path:%s' % str(package))
        # 获取 ota 包所在路径
        out_path = os.path.join(os.path.split(package)[0], 'unpackage')
        # 装载升级包
        resource = load.Load(package, out_path)
        # 返回升级包是否需要重启
        var1 = resource.need_reboot()
        # 查询版本号
        rpc = global_var.get('rpc')
        values = rpc.exec_svc(1, "svc_ota_get_version", need_ack=False, need_rsp=True, timeout=3)
        json_obj = json.loads(values.decode('utf-8'))
        if 'version.ota_boot' in json_obj:
            version = json_obj['version.ota_boot']
        else:
            version = '1.0.0'
        # 比较版本号
        var2 = ota_compare_version(version, "2.0.0")
        # 生成返回值
        if (var1 == False) and (var2 >= 0):
            result = False
        else:
            result = True
        # 生成返回结果
        return result
    except Exception as ex:
        logger.error(ex)
        logger.error(traceback.format_exc())
