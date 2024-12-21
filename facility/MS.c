#include<config.h>
#include<unistd.h>

SFWRAPFUN(MS)

udcell MS_impl_c(char* st, char* rst) {
    cell ms = pop(&st);
    if(ms > 0) {
        usleep(1000 * ms);
    }
    RETURN(st, rst);
}
