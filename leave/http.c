#include "http.h"

const char * status_phrases[] = {
		[100] = "Continue",
		[101] = "Switching Protocols",
		[102] = "Processing",
		[200] = "OK",
		[201] = "Created",
    [202] = "Accepted",
    [203] = "Non-Authoritative Information",
    [204] = "No Content",
    [205] = "Reset Content",
    [206] = "Partial Content",
    [207] = "Multi-Status",
    [208] = "Already Reported",
    [226] = "IM Used",
    [300] = "Multiple Choices",
    [301] = "Moved Permanently",
    [302] = "Found",
    [303] = "See Other",
    [304] = "Not Modified",
    [305] = "Use Proxy",
    [307] = "Temporary Redirect",
    [308] = "Permanent Redirect",
    [400] = "Bad Request",
    [401] = "Unauthorized",
    [402] = "Payment Required",
    [403] = "Forbidden",
    [404] = "Not Found",
    [405] = "Method Not Allowed",
    [406] = "Not Acceptable",
    [407] = "Proxy Authentication Required",
    [408] = "Request Timeout",
    [409] = "Conflict",
    [410] = "Gone",
    [411] = "Length Required",
    [412] = "Precondition Failed",
    [413] = "Request Entity Too Large",
    [414] = "Request-URI Too Long",
    [415] = "Unsupported Media Type",
    [416] = "Requested Range Not Satisfiable",
    [417] = "Expectation Failed",
    [422] = "Unprocessable Entity",
    [423] = "Locked",
    [424] = "Failed Dependency",
    [426] = "Upgrade Required",
    [428] = "Precondition Required",
    [429] = "Too Many Requests",
    [431] = "Request Header Fields Too Large",
    [500] = "Internal Server Error",
    [501] = "Not Implemented",
    [502] = "Bad Gateway",
    [503] = "Service Unavailable",
    [504] = "Gateway Timeout",
    [505] = "HTTP Version Not Supported",
    [506] = "Variant Also Negotiates",
    [507] = "Insufficient Storage",
    [508] = "Loop Detected",
    [510] = "Not Extended",
    [511] = "Network Authentication Required"
};


int length_int(int num) {
		return (num == 0 ? 1 : (int)(log10(num)+1));
}

void * http_create(int version, int status_number) {
		http_len = 0;
		const char * status_phrase = status_phrases[status_number];
		const char * connection;
		if (version > 0)
				connection = "keep-alive";
		else
				connection = "close";
		int len = length_int(version) + length_int(status_number)
				+ strlen(status_phrase) + strlen(connection);
		http = (char *)malloc(sizeof(char) * (len + 11 + 14 + 1));
		sprintf(http, "HTTP/1.%d %d %s\r\nConnection: keep-alive\r\n",
						version, status_number, status_phrase);
		http_len = strlen(http);
}

void * http_content_type(char * content_type, char * charset) {
		int content_type_len = strlen(content_type);
		int charset_len = strlen(charset);
		int str_len = content_type_len + charset_len + 26 + 1;
		char line[str_len];
		sprintf(line, "Content-type: %s; charset=%s\r\n", content_type, charset);
		http_len = http_len + sizeof(char) * str_len;
		http = (char *)realloc(http, http_len);
		strcat(http, line);
}

void * http_header(char * name, char * value) {
		int name_len = strlen(name);
		int value_len = strlen(value);
		int str_len = name_len + value_len + 4 + 1;
		char line[str_len];
		sprintf(line, "%s: %s\r\n", name, value);
		http_len = http_len + sizeof(char) * str_len;
		http = (char *)realloc(http, http_len);
		strcat(http, line);
}

void * http_body(char * body) {
		int body_len = strlen(body);
		int str_len = body_len + 20 + 1;
		char line[str_len];
		http_len = http_len + sizeof(char) + str_len;
		http = (char *)realloc(http, http_len);
		sprintf(line, "Content-Length: %d\r\n\r\n%s", body_len, body);
		strcat(http, line);
}

void * http_free() {
		free(http);
		http_len = 0;
}

