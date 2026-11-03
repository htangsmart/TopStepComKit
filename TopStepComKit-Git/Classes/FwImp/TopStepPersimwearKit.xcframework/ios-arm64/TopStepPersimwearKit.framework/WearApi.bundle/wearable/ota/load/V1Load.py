# -*- coding: utf-8 -*-

import os
import copy
import json

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
    |-- filelist.json               : 升级列表描述文件

升级列表描述文件 JSON 格式介绍:
    [
        {
            "type": "file",
            "name": "rtthread.rbl",
            "size": 953872,
            "md5": "041740c145d95ab3dbfe37a897ea35b8",
            "sha1": "fdb9fc16a0ddaf0c319c61e074358e6abff0cec4",
            "crc32": "12c6fee9",
            "local_path": "download/ota/rtthread.rbl",
            "remote_path": "download/ota/rtthread.rbl"
        },
        ...
    ]

为后续的扩展性，需要将当前的升级包信息进行转换。主要转换 JSON 格式的定义
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
                    "local": 'system'               # 本地路径 (这个参数主要是具体的执行方法使用)
                    "remote": 'system'              # 远端路径 (这个参数主要是具体的执行方法使用)
                    "path": 'x:/system'             # 本地绝对地址
                    "filelist":
                        [
                            {       # 文件列表描述如下:
                                "path": '/system/ota/rtthread.rbl'          # 本地绝对路径
                                "type": 'file',     # 文件类型
                                "local": 'system/ota/rtthread.rbl',         # 本地路径
                                "remote": 'system/ota/rtthread.rbl',        # 远端路径
                                "size": 1234                    # 文件大小
                                "crc32": '0x12345678'           # crc32 校验值
                            }
                        ]
                },
            ]
    }
"""


class V1Load(object):
    """
    资源文件校验加载类
    :param __filelist_json__: 原始 json 文件
    :param __upgrade_info__: 升级信息
    """

    def __init__(self, unpackage_path):
        """
        :param unpackage_path: 压缩包解压路径
        """
        super().__init__()

        # 查找 filelist.json 文件
        file_list_path = os.path.abspath(os.path.join(unpackage_path, 'filelist.json'))
        if not os.path.isfile(file_list_path):
            raise Exception('Not find %s' % file_list_path)
        # 解析 json 文件
        with open(file_list_path) as f:
            file_list = json.loads(f.read())
        if not isinstance(file_list, list):
            raise Exception('Illegal field type. filelist.json')
        # 顶层目录字典
        locals = {}
        # 解析 filelist.json 中的文件信息
        for i in file_list:
            if 'type' not in i or i["type"] not in ('file', 'directory'):
                continue
            if 'crc32' not in i:
                continue
            if 'size' not in i:
                continue
            # 构造升级文件描述信息
            fileinfo = copy.deepcopy(i)
            fileinfo["path"] = os.path.abspath(os.path.join(unpackage_path, 'ota', fileinfo["local_path"])).replace('\\', '/')
            fileinfo["local"] = fileinfo["local_path"].replace('\\', '/')
            fileinfo["remote"] = fileinfo["remote_path"].replace('\\', '/')
            # 获取该文件的顶层目录
            remote_path = i["remote_path"].replace('\\', '/')
            if remote_path[0] == '/':
                top_dir = remote_path.split('/', 2)[1]
            else:
                top_dir = remote_path.split('/', 1)[0]
            # 将文件添加到对应的顶层目录中
            if top_dir in locals:
                locals[top_dir].append(fileinfo)
            else:
                locals[top_dir] = [fileinfo]
        # 构造升级描述信息
        upgrade_info = {"project": 'C18',
                        "version": 'V0.1',
                        "steps": []}
        # 添加升级模式检查步骤
        upgrade_info["steps"].append({
            "uses": 'enter_upgrade_mode',
            "time": 5
        })
        # 添加文件夹删除步骤
        for key in locals.keys():
            upgrade_info["steps"].append({
                "uses": 'directory_remove',
                "type": 'directory',
                "remote": key,
                "time": len(locals[key]) if len(locals[key]) > 10 else 10
            })
        # 添加文件夹同步步骤
        for key in locals.keys():
            total_size = 0
            for fi in locals[key]:
                if fi["type"] == 'file' and fi["size"] > 0:
                    total_size = total_size + fi["size"]
            t = int(total_size / (4 * 1024)) + 1
            upgrade_info["steps"].append({
                "uses": 'directory_upgrade',
                "type": 'directory',
                "path": os.path.abspath(os.path.join(unpackage_path, 'ota', key)).replace('\\', '/'),
                "local": key,
                "remote": key,
                "time": t,
                "filelist": locals[key]
            })
        # 添加文件夹检查步骤
        for key in locals.keys():
            upgrade_info["steps"].append({
                "uses": 'check_dir_upgrade',
                "type": 'directory',
                "path": os.path.abspath(os.path.join(unpackage_path, 'ota', key)).replace('\\', '/'),
                "local": key,
                "remote": key,
                "time": len(locals[key]) * 3,
                "filelist": locals[key]
            })
        # 初始化对象
        self.__upgrade_info__ = upgrade_info
        self.__filelist_json__ = file_list

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
        return "V0.1"


def Load(files):
    return V1Load(files)
