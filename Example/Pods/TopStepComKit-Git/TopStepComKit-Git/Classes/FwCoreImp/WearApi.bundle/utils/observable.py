from utils.singleton import singleton


class Observable:
    def __init__(self):
        self.observers = []

    def add_observer(self, observer):
        self.observers.append(observer)

    def remove_observer(self, observer):
        self.observers.remove(observer)

    def notify_observers(self, data):
        for observer in self.observers:
            observer.update(data)

@singleton
class ServiceConnObservable(Observable):
    def __init__(self):
        super().__init__()

@singleton
class FrameObservable(Observable):
    def __init__(self):
        super().__init__()

class Observer:
    def update(self, data):
        pass

