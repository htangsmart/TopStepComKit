import ubjson
import json
from wearable.files.pull import pull
import os
from .py_pacth_context import PatchContext
from pathlib import Path
import traceback
import logging
import global_var
import importlib.util
import sys
import types

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearservice.py_patch'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

MAX_VALUE_SIZE = 40000

"""
1. 拉取脚本文件
2. 导入脚本文件
3. 执行脚本文件中的 main 方法，传入参数
"""

def load_module_from_path( file_path):
    """
    从绝对路径加载 Python 模块
    :param module_name: 加载后的模块名
    :param file_path: Python 文件的绝对路径
    :return: 加载的模块
    """
    module_name = "rtthread_extension"
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None:
        raise ImportError(f"无法从路径 {file_path} 创建模块 {module_name}")
    
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module  # 将模块放入 sys.modules
    spec.loader.exec_module(module)  # 执行模块的代码
    return module

def exec_py_patch(input):
    input = ubjson.loadb(input)

    plugin_dir_path = create_plugin_path(input['app_id'])

    plugin_ctx = PatchContext(plugin_dir_path)
    params = json.loads(input['params'])

    plugin_pull_success = True
    plugin_pull_failed_reason = ""

    def __pull_plugin_callback(event, status, path, start_time, cur_size, total_size):
        nonlocal plugin_pull_success, plugin_pull_failed_reason
        if event == "onSuccess":
            plugin_pull_success = True
        elif event == "onFailed":
            plugin_pull_success = False
            plugin_pull_failed_reason = json.dumps(status)

    pull(os.path.join(plugin_dir_path, "extension.py"), params['plugin'], False, {}, callback=__pull_plugin_callback)

    if not plugin_pull_success:
        return ubjson.dumpb({"code": 200, "data": {"code": 500, "msg": "pull script file failed {}".format(plugin_pull_failed_reason)}})

    try:
        logger.debug("watch app {} exec py_patch".format(input["app_id"]))
        plugin_path = os.path.join(plugin_dir_path, "extension.py")
        # plugin_module = importlib.import_module('wearable.py_patch.' + input['app_id'].replace('.', '_') + '.extension')
        plugin_module = load_module_from_path(plugin_path)

        plugin_module_main_fun = getattr(plugin_module, 'main')
        res_data = plugin_module_main_fun(plugin_ctx, input['params'])
    except Exception as e:
        logger.error(e)
        logger.error(traceback.format_stack())
        res_data = json.dumps({"code": 500, "msg": e.__str__()})

    result = ubjson.dumpb({'code': 200, "data": res_data})

    if len(result) > MAX_VALUE_SIZE:
        return ubjson.dumpb({"code": 200, "data": {"code": 500, "msg": "Data exceeds limit size {}".format(MAX_VALUE_SIZE)}})

    return result


def create_plugin_path(app_id):
    root_path = global_var.get("log_path")

    plugin_dir_path = os.path.join(root_path, app_id.replace('.', '_'))

    if not Path(plugin_dir_path).exists:
        os.makedirs(plugin_dir_path)

    return plugin_dir_path
