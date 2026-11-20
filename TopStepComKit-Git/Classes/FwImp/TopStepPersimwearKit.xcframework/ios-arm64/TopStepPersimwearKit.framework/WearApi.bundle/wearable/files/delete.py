import logging
import os
from .utils import *
from wearable import path

LOG_LVL = logging.INFO
LOG_TAG = 'wearable.files.utils'
logger = logging.getLogger(LOG_TAG)
logger.setLevel(LOG_LVL)

def delete_file(input):
    result = remove(input['remote_path'])
    logger.info("remove file result {}".format(result.signed()))
    if(result.signed() == 0):
        return json_lpc.gen_success_output_json()
    else:
        return json_lpc.gen_failed_output_json("No such file or file is opened")
    
def remove_all(remote):
    remote_path = path.Path(remote)
    logger.info('remove all. path:%s' % remote)
    if remote_path.isdir('.'):
        # 遍历远端路径
        def __list_remote_dir(p):
            nonlocal remote_path
            tmp_list = remote_path.listdir(p)
            file_list = []
            for l in tmp_list:
                tmp_path = os.path.join(p, l).replace('\\', '/')
                if remote_path.isdir(tmp_path):
                    # 递归查找远端路径信息
                    file_list = file_list + [tmp_path]
                    file_list = file_list + __list_remote_dir(tmp_path)
                elif remote_path.isfile(tmp_path):
                    file_list = file_list + [tmp_path]
            return file_list

        # 获取远端路径信息
        remote_file_list = __list_remote_dir('.')
        # 执行删除操作
        remote_file_list = sorted(remote_file_list, reverse=True)
        for i in remote_file_list:
            remote_asb_path = remote_path.abspath(i)
            logger.info('remove path:%s' % os.path.normpath(remote_asb_path))
            remove(remote_asb_path)

    elif remote_path.isfile('.'):
        remote_asb_path = remote_path.abspath('.')
        remove(remote_asb_path)


    