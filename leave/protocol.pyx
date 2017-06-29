# cython: language_level=3

import asyncio
import r3py


cdef class Protocol:

    def __cinit__(self, app, loop):
        self.app = app
        self.loop = loop
        self.asyncio_protocol = asyncio.Protocol()
        self.request = Request(self)
        self.router_compile()

    cdef router_compile(self):
        self._node = r3py.r3.r3_tree_create(10)
        self._match_entry = r3py.r3.match_entry_create(b"/")
        for route in self.app.config.router.routes:
            r3py.r3.r3_tree_insert_route(self._node, route.methods, route.uri,
                                         < void *><object> route.handler)

    cpdef connection_made(self, object transport):
        self.transport = transport
        self.asyncio_protocol.connection_made(self.transport)

    cpdef data_received(self, data):
        self.parsing(< char * >data)

    cpdef connection_lost(self, exc):
        self.asyncio_protocol.connection_lost(exc)

    cdef parsing(self, char * data):
        self.request.parse(<char *> data)
        #self.transport.write(b"HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 4\r\nConnection: keep-alive\r\n\r\ntest")
        #r3py.r3.match_entry_free(self._match_entry)
        #self._match_entry = r3py.r3.match_entry_create(self.request.uri)
        self._match_entry.path.base = self.request.uri
        self._match_entry.path.len = len(self.request.uri)
        self._match_entry.request_method = getattr(r3py, self.request.method.decode())
        self._route = r3py.r3.r3_tree_match_route(self._node, self._match_entry)
        #r3py.r3.match_entry_free(self._match_entry)
        handler = None
        if self._route:
            handler = <object><void *>self._route.data
            task = self.loop.create_task(handler(self.request))
            task.add_done_callback(self.write_future)
            return
        self.transport.write(self.request.response.text(b"Not found", status_number=200, headers={}))
        self.transport_is_close()

    def write_future(self, future):
        self.transport.write(future.result())
        self.transport_is_close()

    def transport_is_close(self):
        if not self.request.should_keep_alive():
            self.transport.close()        

    def __dealloc__(self):
        r3py.r3.r3_tree_free(self._node)
        r3py.r3.match_entry_free(self._match_entry)

