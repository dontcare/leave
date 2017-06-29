# cython: language_level=3

import ujson


cdef class Response:

    def __cinit__(self, request):
        self.request = request

    def text(self, bytes body, status_number=200, headers={}, charset=b"utf-8"):
        return self.compile(body, status_number, headers, b"text/plain", charset)

    def json(self, dict j, status_number=200, headers={}, charset=b"utf-8"):
        return self.compile(ujson.dumps(j).encode(), status_number, headers, b"application/json", charset)        

    cdef compile(self, body, status_number, headers, content_type, charset):
        http_create(self.request.pico_minor_version, 200)
        http_content_type(< char * >content_type, < char * >charset)
        for name, value in headers.items():
            http_header( < char * >name, < char  * >value)
        http_body( < char * >body);
        h = <bytes > http
        http_free()
        return h
