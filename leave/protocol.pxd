# cython: language_level=3

from .request cimport Request
cimport r3py.r3

cdef class Protocol:

    cdef:
        object app
        object loop
        public object transport
        object asyncio_protocol

        Request request
        r3py.r3.R3Node * _node
        r3py.r3.R3Route * _route
        r3py.r3.match_entry * _match_entry

    cpdef connection_made(self, object transport)
    cpdef data_received(self, data)
    cpdef connection_lost(self, exc)
    cdef parsing(self, char * data)
    cdef router_compile(self)
