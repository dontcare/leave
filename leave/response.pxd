# cython: language_level=3

from .request cimport Request


cdef extern from "http.h":

    char * http
    int http_len
    void * http_create(int version, int status_number)
    void * http_header(char * name, char * value)
    void * http_content_type(char * content_type, char * charset)
    void * http_body(char * body)
    void * http_free()

cdef class Response:

    cdef:
        Request request

    cdef compile(self, body, status_number, headers, content_type, charset)
    # cdef compile_http(self, int status_number)
    # cdef compile_content_type(self, bytes content_type, bytes charset)
    # cdef compile_headers(self, dict headers)
    # cdef compile_content(self, bytes body)
