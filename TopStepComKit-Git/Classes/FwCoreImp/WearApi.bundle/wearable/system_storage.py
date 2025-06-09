import json


import global_var
from urpc.src.ffi import *
from wearable.json_lpc import gen_success_output_json

LOG_LVL = logging.INFO
LOG_TAG = 'persimwear.dcm'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

def service_system_storage_get(input):
    rpc = global_var.get('rpc')
    values = rpc.exec_svc(1, "svc_systemstorage_get", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=3)
    output = gen_success_output_json()
    output["values"] = json.loads(values.decode('utf-8'))
    return output

def service_system_storage_set(input):
    rpc = global_var.get('rpc')
    rpc.exec_svc(1, "svc_systemstorage_set", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=3)
    output = gen_success_output_json()
    return output