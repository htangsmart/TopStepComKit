from mcf.aslog import aslog
from wearable.boot.clients import *
from wearable.boot.common import register_lpc_svc
import traceback

LOG_LVL = logging.DEBUG
LOG_TAG = 'wearable.boot.boot'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

PUBLIC_ID = 254


def run(client_name=''):
    if not global_var.has('rpc'):
        try:
            register_lpc_svc()
            json_lpc.register_svc(get_server_status)
            

            # json_lpc.register_svc(daemon_init)
            json_lpc.register_svc(has_device_connected)
            rpc_init(client_name)
        except Exception as e:
            logger.error(traceback.format_exc())
