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
        self._match_entry.path.base = self.request.uri
        self._match_entry.path.len = len(self.request.uri)
        self._match_entry.request_method = getattr(r3py, self.request.method.decode())
        self._route = r3py.r3.r3_tree_match_route(self._node, self._match_entry)
        handler = None
        if self._route:
            handler = <object><void *>self._route.data
            self.loop.create_task(handler(self.request))
            return
        self.request.response.error(404)
 
    def transport_is_close(self):
        if not self.request.should_keep_alive():
            self.transport.close()        

    def __dealloc__(self):
        r3py.r3.r3_tree_free(self._node)
        r3py.r3.match_entry_free(self._match_entry)

