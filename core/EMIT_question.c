#include<config.h>

#include<sys/select.h>
#include<stdio.h>

SFWRAPFUN(EMIT_question)

udcell EMIT_question_impl_c(char* st, char* rst) {
    fd_set s;
    FD_ZERO(&s);
    FD_SET(1, &s);
    struct timeval t = {
        .tv_sec = 0,
        .tv_usec = 0
    };
    switch(select(1, 0, &s, 0, &t)) {
        case 0:
            push(0, &st);
            break;
        case 1:
            push(-1, &st);
            break;
        default:
            perror("select");
            push(0, &st);
            break;
    }
    RETURN(st, rst);
}

