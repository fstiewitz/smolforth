#include<config.h>
#include<time.h>

SFWRAPFUN(TIME_and_DATE)

udcell TIME_and_DATE_impl_c(char* st, char* rst) {
    time_t t = time(0);
    if(t == -1) {
        push(0, &st);
        RETURN(st, rst);
    }
    struct tm tm;
    if(!localtime_r(&t, &tm)) {
        push(0, &st);
        RETURN(st, rst);
    }
    push(tm.tm_sec, &st);
    push(tm.tm_min, &st);
    push(tm.tm_hour, &st);
    push(tm.tm_mday, &st);
    push(tm.tm_mon + 1, &st);
    push(tm.tm_year + 1900, &st);
    push(-1, &st);
    RETURN(st, rst);
}
