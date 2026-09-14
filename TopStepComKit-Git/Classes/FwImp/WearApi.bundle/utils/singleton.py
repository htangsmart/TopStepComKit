
def singleton(cls):
    _instance = {}
    # 创建一个字典用来保存被装饰类的实例对象 _instance = {}
    def _singleton(*args, **kwargs):
        # 判断这个类有没有创建过对象，没有新创建一个，有则返回之前创建的  
        if cls not in _instance:
            _instance[cls] = cls(*args, **kwargs)
        return _instance[cls]
    return _singleton