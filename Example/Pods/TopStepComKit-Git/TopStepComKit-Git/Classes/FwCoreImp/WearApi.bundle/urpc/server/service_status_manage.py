import global_var
from wearable import json_lpc
import logging
from utils.singleton import singleton
from mcf.link.link import MCFLinkStatus
import time

# TODO 目前仅支持一个 daemon
DAEMON_ID = 1


LOG_LVL = logging.DEBUG
LOG_TAG = 'service_status_manage'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)


@singleton
class ServiceStatusManage():
  def __init__(self):
    self.link_layer_status = None
    self.wear_service_status = None
    self.session_uuid = None
  
  def set_link_layer_status(self, status):
    self.link_layer_status = status
    MCFLinkStatus().set_link_status(status)

  
  def set_wear_service_status(self, status):
    app_server = global_var.get("app_server")
    logger.debug("wearService connect status changed, new status: " + str(status))
    self.session_uuid = int(time.time() * 1000)
    # 避免检测服务导致重复触发回调
    if status != self.wear_service_status:
      self.wear_service_status = status
      if app_server:
        app_server.daemon_device[DAEMON_ID]["connect"] = status
        app_server.notice_client_daemon_changed({'connect': status})
      if status:
        msg = {'code': 200, 'msg': 'success', 'values': ''}
      else:
        msg = {'code': 502, 'msg': 'WearService Disconnect', 'values': ''}
      input = {'module': 'service.init', 'event': 'failed', 'msg': msg}
      json_lpc.invoke_callback(input)

  def get_session_uuid(self):
    return self.session_uuid


  def get_link_layer_status(self):
    return self.link_layer_status
  
  def get_wear_service_status(self):
    return self.wear_service_status