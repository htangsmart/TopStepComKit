"""
用于存储脚本执行是的一些上下文信息，
在执行脚本的 main 方法是作为第一个参数传入
"""

class PatchContext:
    def __init__(self, root_path):
        self._root_path = root_path

    @property
    def extension_path(self):
        return self._root_path