#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

/*
const char * status_phrases[] = {
    [100] = "Continue",
    [101] = "Switching Protocols",
    [102] = "Processing",
    [200] = "OK"
}
*/
/*
inline const char * http_compile(const char * http_version, int status_number,
                                 const char * content_type, const char * charset,
                                 const char * body) {

    char * http = malloc(sizeof(char*) * )
    sprintf(http, "HTTP/%s %d %s", http_version, status_number,
            status_phrases[status_number])
    return http
}
*/

//int http_compile(const char * http_version, int status_number,
                   // const char * content_type, const char * charset,
                   // const char * body, const char * http)

char * http;
int http_len;

void * http_create(int version, int status_number);
void * http_content_type(char * content_type, char * charset);
void * http_header(char * name, char * value);
void * http_body(char * body);
void * http_free(void);

int length_int(int num);
