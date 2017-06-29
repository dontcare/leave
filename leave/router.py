import collections
import typing

Route = collections.namedtuple(
    'Route',
    ['uri', 'handler', 'methods'])


class Router:

    __slots__ = ['routes']

    def __init__(self):
        self.routes = typing.List[Route]
        self.routes = []

    def add(self, uri, methods, handler):
        #for method in methods:
        route = Route(uri=uri, handler=handler, methods=methods)
        self.routes.append(route)
