#define _LARGEFILE64_SOURCE
#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(REPOSITION_FILE)

udcell REPOSITION_FILE_impl_c(char* st, char* rst) {
    cell fid = pop(&st);
    udcell off = udpop(&st);
    off64_t l = lseek64(fid, off, SEEK_SET);
    if(l == -1) {
        push(-1, &st);
    } else {
        push(0, &st);
    }
    RETURN(st, rst);
}
