# -*- coding: utf-8 -*-

import os
from wearable.ota.excall import excall


# 从手表获取当前版本信息状态
def service_ota_get_version(param=None):
    return excall(os.path.join(os.path.split(__file__)[0], 'service/service_port.py'), 'service_ota_get_version', param)

# 进入升级模式
def service_ota_set_upgrade_state(param):
    return excall(os.path.join(os.path.split(__file__)[0], 'service/service_port.py'), 'service_ota_set_upgrade_state', param)


# 获取升级状态
def service_ota_get_upgrade_state(param=None):
    return excall(os.path.join(os.path.split(__file__)[0], 'service/service_port.py'), 'service_ota_get_upgrade_state', param)


# 开始升级
def service_ota_update(param):
    return excall(os.path.join(os.path.split(__file__)[0], 'service/service_port.py'), 'service_ota_update', param)


# 退出升级
def service_ota_quit(param):
    return excall(os.path.join(os.path.split(__file__)[0], 'service/service_port.py'), 'service_ota_quit', param)

