from wearable.time import service_device_info
from wearable.dcm import service_dcm_get, service_dcm_set
from wearable.dial import *
from wearable.notification import service_notification_push
from wearable.system_data import service_system_data_sync
from wearable.ota.service import *
from wearable.testcase import *
from wearable.time import service_time_sync
from wearable.tsdb import service_tsdb_query_count, service_tsdb_query
from wearable.user_app import *
from wearable.speed import *
from wearable.boot.clients import sport_health_client
from wearable.system_storage import service_system_storage_get, service_system_storage_set
from wearable.settings import service_settings_get, service_settings_set, service_dirs_info, service_profile_toggle, service_ls_dir
from wearable.contacts import service_contacts_sync, service_contacts_get
from wearable.env import service_env_get
from wearable.log import export_log, export_device_log

from wearable.files.push import service_file_push
from wearable.files.pull import service_file_pull
from wearable.files.delete import delete_file

# 注册 lpc 服务
def register_lpc_svc():
    # 注册给到 Java 的 JSON LPC 服务
    # 注册 lpc 服务是默认使用单例模式
    json_lpc.register_svc(service_dcm_get)
    json_lpc.register_svc(service_dcm_set)
    json_lpc.register_svc(service_file_push)
    json_lpc.register_svc(service_file_pull)
    json_lpc.register_svc(delete_file)
    json_lpc.register_svc(service_notification_push)
    json_lpc.register_svc(service_system_data_sync)
    json_lpc.register_svc(service_time_sync)
    json_lpc.register_svc(service_dial_install)
    json_lpc.register_svc(service_dial_uninstall)
    json_lpc.register_svc(service_dial_apply)
    json_lpc.register_svc(service_dial_get_current)
    json_lpc.register_svc(service_dial_info)
    json_lpc.register_svc(service_dial_hide)
    json_lpc.register_svc(service_dial_unhide)
    json_lpc.register_svc(service_set_dial_order_info)
    json_lpc.register_svc(service_user_app_uninstall)
    json_lpc.register_svc(service_user_app_install)
    json_lpc.register_svc(service_user_app_info)
    json_lpc.register_svc(service_app_msg_recv)
    json_lpc.register_svc(service_app_data_channel_send)
    json_lpc.register_svc(service_app_launch)
    json_lpc.register_svc(service_app_ping)
    json_lpc.register_svc(service_app_installed)
    # json_lpc.register_svc(testcase_push_pull_file)
    # json_lpc.register_svc(testcase_push_pull_sync_file)
    # json_lpc.register_svc(testcase_push_sync_file)
    # ========== OTA begin ==========
    json_lpc.register_svc(service_ota_get_version)
    json_lpc.register_svc(service_ota_set_upgrade_state)
    json_lpc.register_svc(service_ota_get_upgrade_state)
    json_lpc.register_svc(service_ota_update, blocking=False)
    json_lpc.register_svc(service_ota_quit)
    # ========== OTA end ==========
    json_lpc.register_svc(service_speed)
    json_lpc.register_svc(service_echo)
    json_lpc.register_svc(service_lost_start)
    json_lpc.register_svc(service_lost_stop)
    json_lpc.register_svc(sport_health_client)
    json_lpc.register_svc(service_device_info)

    json_lpc.register_svc(service_system_storage_get)
    json_lpc.register_svc(service_system_storage_set)
    json_lpc.register_svc(service_settings_get)
    json_lpc.register_svc(service_settings_set)
    json_lpc.register_svc(service_profile_toggle)
    json_lpc.register_svc(service_ls_dir)
    json_lpc.register_svc(service_dirs_info)
    json_lpc.register_svc(service_contacts_sync)
    json_lpc.register_svc(service_contacts_get)
    json_lpc.register_svc(service_env_get)
    json_lpc.register_svc(service_tsdb_query_count)
    json_lpc.register_svc(service_tsdb_query)
    json_lpc.register_svc(export_log)
    json_lpc.register_svc(export_device_log)


