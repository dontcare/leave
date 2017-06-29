# cython: language_level=3

import ujson


cdef class Response:

    def __cinit__(self, request):
        self.request = request

    def text(self, bytes body, status_number=200, headers={}, charset=b"utf-8"):
        self.compile(body, status_number, headers, b"text/plain", charset)

    def json(self, dict j, status_number=200, headers={}, charset=b"utf-8"):
        self.compile(ujson.dumps(j).encode(), status_number, headers, b"application/json", charset)

    def error(self, status_number):
        self.compile(b"", status_number, {}, content_type=b"text/plain", charset=b"utf-8")

    cdef compile(self, body, status_number, headers, content_type, charset):
        http_create(self.request.pico_minor_version, status_number)
        http_content_type(< char * >content_type, < char * >charset)
        for name, value in headers.items():
            http_header( < char * >name, < char  * >value)
        http_body( < char * >body);
        h = <bytes > http
        self.request.protocol.transport.write(h)
        self.request.protocol.transport_is_close()
        http_free()
