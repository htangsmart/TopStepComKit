import json
import global_var
from urpc.src.ffi import *
from wearable.json_lpc import gen_success_output_json

LOG_LVL = logging.INFO
LOG_TAG = 'wearable.contacts'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

def service_contacts_sync(input):
    rpc = global_var.get('rpc')
    rpc.exec_svc(1, "svc_contacts_sync", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=10)
    output = gen_success_output_json()
    return output

def service_contacts_get(input):
    rpc = global_var.get('rpc')
    output = gen_success_output_json()
    values = rpc.exec_svc(1, "svc_contacts_get", bytearray(json.dumps(input), encoding="utf8"), need_ack=False, need_rsp=True, timeout=10)
    output["values"] = json.loads(values.decode('utf-8'))
    return output