# cython: language_level=3

from libc.stdlib cimport calloc, free


cdef class Request:

    def __cinit__(self, protocol):
        self.protocol = protocol
        self.headers = {}
        self.pico_headers = <httpparser.pico.phr_header * >calloc(100, sizeof(httpparser.pico.phr_header))
        self.pico_num_headers = sizeof(
            self.pico_headers) * sizeof(self.pico_headers[0])
        self.response = Response(self)

    cdef should_keep_alive(self):
        return bool(self.pico_minor_version)

    cdef parse(self, char * buf):
        cdef:
            size_t buf_len

        buf_len = len(buf)

        phr = httpparser.pico.phr_parse_request(
            buf,
            buf_len,
            < const char ** > & self.pico_method,
            & self.pico_method_len,
            < const char ** > & self.pico_uri,
            & self.pico_uri_len,
            & self.pico_minor_version,
            self.pico_headers,
            & self.pico_num_headers,
            0
        )
        if not self.headers:
            for i in range(0, self.pico_num_headers):
                name_len = self.pico_headers[i].name_len
                name = self.pico_headers[i].name[:name_len]
                value_len = self.pico_headers[i].value_len
                value = self.pico_headers[i].value[:value_len]
                self.headers[name] = value
        self.http_version = b"1.%d" % self.pico_minor_version
        self.method = <bytes > self.pico_method[:self.pico_method_len]
        self.uri = <bytes > self.pico_uri[:self.pico_uri_len]
        self.body = <bytes > buf[phr:]

    def __dealloc__(self):
        free( < void * >self.pico_headers)
