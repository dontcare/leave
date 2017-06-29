# cython: language_level=3

cimport httpparser.pico

from .response cimport Response

cdef class Request:

    cdef:
        httpparser.pico.phr_header * pico_headers
        public int pico_minor_version
        size_t pico_num_headers
        const char * pico_method
        size_t pico_method_len
        const char * pico_uri
        size_t pico_uri_len

        public Response response

        public object protocol
        public dict headers
        public bytes http_version
        public bytes method
        public bytes uri
        public bytes body

    cdef should_keep_alive(self)
    cdef parse(self, char * data)
