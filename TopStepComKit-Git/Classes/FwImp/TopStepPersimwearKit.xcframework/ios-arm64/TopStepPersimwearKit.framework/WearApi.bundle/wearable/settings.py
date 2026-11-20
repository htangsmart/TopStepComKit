
import json


import global_var
from urpc.src.ffi import *
from wearable.json_lpc import gen_success_output_json

LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.dcm'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

def service_settings_get(input):
    rpc = global_var.get('rpc')
    values = rpc.exec_svc(1, "svc_settings_get", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=3)
    output = gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output

def service_settings_set(input):
    rpc = global_var.get('rpc')
    rpc.exec_svc(1, "svc_settings_set", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=3)
    output = gen_success_output_json()
    return output

# 获取指定路径所在分区的 存储块总数量、剩余存储块数量、存储块大小
def service_dirs_info(input):
    rpc = global_var.get('rpc')
    values = rpc.exec_svc(1, "directory_info", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=3)
    output = gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output

# 开启/关闭性能分析
def service_profile_toggle(input):
    if input['status']:
        flag = Arg(U8 | ARRAY, bytearray( '1' + '\0', encoding="utf8"))
    else:
        flag = Arg(U8 | ARRAY, bytearray( '0' + '\0', encoding="utf8"))
    rpc = global_var.get('rpc')
    rpc.exec_ffi_func(1, "svc_profiling_control", [flag], need_ack=False, need_rsp=True, timeout=3)
    output = gen_success_output_json()
    return output

def service_ls_dir(input):
    rpc = global_var.get('rpc')

    result = rpc.exec_svc(1, "lsdir_svc", bytearray(input["path"] + '\0', encoding="utf8"), need_ack=False, need_rsp=True, timeout=5)

    output = gen_success_output_json()
    output['values'] = json.loads(result.decode('utf-8'))

    return output