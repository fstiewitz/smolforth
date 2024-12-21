#define _LARGEFILE64_SOURCE
#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(RESIZE_FILE)

udcell RESIZE_FILE_impl_c(char* st, char* rst) {
    cell id = pop(&st);
    udcell size = udpop(&st);
    if(ftruncate64(id, size)) {
        push(-1, &st);
    } else {
        push(0, &st);
    }
    RETURN(st, rst);
}
