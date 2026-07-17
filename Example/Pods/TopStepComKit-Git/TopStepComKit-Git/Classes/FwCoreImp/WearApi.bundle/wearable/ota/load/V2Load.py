# -*- coding: utf-8 -*-

import json, copy, os

"""
压缩包目录介绍:
    |-- ota                         : 该目录下存放升级所需文件
    |   |-- system                  : 远端系统文件夹
    |   |   |-- apps                : 系统应用目录
    |   |   |-- fonts               : 字体文件
    |   |   |-- lib                 : 公共脚本库
    |   |   |-- widgets             : 其他
    |   |-- download                : 远端下载文件夹
    |   |   |-- ota                 : 远端升级文件夹
    |   |   |   |-- rtthread.rbl    : 升级固件
    |-- resource.json               : 资源包描述文件

    资源包描述文件 JSON 格式如下:
        {
            "project":"C18",                # 项目代号（必须项）
            "version":"V0.1",               # 固件版本（必须项）
            "steps":[                 # 升级事务
                {"uses":'directory_upgrade', "type":'directory', "remote": "system"},
                ...
            ]
        }
升级包中的配置文件是无法直接使用的，部分路径需要根据解压地址进行填充完善
转换后的 JSON 格式介绍:
    {
        "project":"C18",        # 项目名
        "version":"V0.1",       # 升级包版本
        "steps":                # 升级步骤
            [
                {               # 步骤描述信息如下
                    "uses":'directory_upgrade',     # 步骤名，在 upgrade 目录下定义了若干步骤，这里定义了要执行的方法
                    "type":'directory',             # 类型: directory 文件夹、 file 文件 (还有其他类型，这个参数主要是具体的执行方法使用)
                    "size": 1234                    # 文件/文件夹大小 (这个参数主要是具体的执行方法使用)
                    "local": 'x:/system'            # 本地绝对路径 (相对于 path 的路径，这个参数主要是具体的执行方法使用)
                    "remote": 'x:/system'           # 远端绝对路径 (这个参数主要是具体的执行方法使用)
                    "filelist":
                        [
                            {       # 文件列表描述如下:
                                "type": 'file',     # 文件类型
                                "local": 'x:/system/ota/rtthread.rbl',    # 本地绝对路径
                                "remote": '/system/ota/rtthread.rbl',     # 远端绝对路径
                                "size": 1234                    # 文件大小
                                "crc32": '0x12345678'           # crc32 校验值
                            }
                        ]
                },
            ]
    }
"""

class V2Load(object):
    """
    资源文件校验加载类
    :param __version__:         升级包版本
    :param __config_json__:     原始 json 文件
    """
    def __init__(self, unpackage_path):
        """
        """
        super().__init__()

        # 查找 filelist.json 文件
        config_file_path = os.path.abspath(os.path.join(unpackage_path, 'config.json'))
        if not os.path.isfile(config_file_path):
            raise Exception('Not find %s' % config_file_path)
        # 解析 json 文件
        with open(config_file_path) as f:
            config = json.loads(f.read())
        # 检查配置文件成员
        if 'steps' not in config or not isinstance(config['steps'], list):
            raise Exception('item \'steps\' not find. Illegal field type. config.json')
        if 'version' not in config or not isinstance(config['version'], str):
            raise Exception('item \'version\' not find. Illegal field type. resource.json')
        if 'project' not in config or not isinstance(config['project'], str):
            raise Exception('item \'project\' not find. Illegal field type. resource.json')
        # 遍历列表，读取需要升级的文件
        upgrade_info = copy.deepcopy(config)
        for item in upgrade_info['steps']:
            def __load_data(_list):
                for i in _list:
                    if 'path' not in i:
                        continue
                    i["path"] = os.path.abspath(os.path.join(unpackage_path, 'ota', i["local"])).replace('\\', '/')
                    if 'filelist' in i:
                        __load_data(i["filelist"])
            if 'path' not in item:
                continue
            # 更新下路径信息
            item["path"] = os.path.abspath(os.path.join(unpackage_path, 'ota', item["local"])).replace('\\', '/')
            if 'filelist' in item:
                __load_data(item["filelist"])

        self.__upgrade_info__ = upgrade_info
        self.__version__ = config['version']
        # 设备是否需要重启，默认需要重启
        if 'deviceNeedReboot' in config:
            self.__need_reboot__ = config['deviceNeedReboot']
        else:
            self.__need_reboot__ = True
        # 升级是否允许中途退出，默认不允许退出
        if 'allowQuitHalfway' in config:
            self.__allow_quit__ = config['allowQuitHalfway']
        else:
            self.__allow_quit__ = False

    def steps(self):
        """
        获取资源描述列表
        """
        return self.__upgrade_info__["steps"]

    def config(self):
        """
        获取完整配置
        :return:
        """
        return self.__upgrade_info__

    def version(self):
        """
        获取升级包版本
        """
        return self.__version__

    def need_reboot(self):
        """
        获取升级包是否要求设备重启
        """
        return self.__need_reboot__

    def allow_quit(self):
        """
        获取升级包是否允许退出升级
        """
        return self.__allow_quit__

def Load(files):
    return V2Load(files)
