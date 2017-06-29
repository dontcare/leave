import functools

import leave.router
import r3py


class Config:

    __slots = ['router', 'middlewares', 'listeners']

    def __init__(self):
        self.router = leave.router.Router()
        self.middlewares = {}
        self.listeners = {
            'before_start_server': [],
            'before_stop_server': []
        }

    def add_middleware(self, name, middleware):
        self.middlewares[name].append(middleware)

    def add_listener(self, name, listener):
        self.listeners[name].append(listener)

    def middleware(self, name):
        return functools.partial(self.add_middleware, name)

    def listener(self, name):
        return functools.partial(self.add_listener, name)

    def callback_listeners(self, app, loop, name):
        for listener in self.listeners[name]:
            loop.create_task(listener(app))

    def add_route(self, uri, methods, handler):
        self.router.add(uri, methods, handler)

    def route(self, uri, methods=r3py.ALL):
        return functools.partial(self.add_route, uri, methods)
