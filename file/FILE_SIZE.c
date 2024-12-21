#define _LARGEFILE64_SOURCE
#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(FILE_SIZE)

udcell FILE_SIZE_impl_c(char* st, char* rst) {
    cell fid = pop(&st);
    off64_t l = lseek64(fid, 0, SEEK_CUR);
    if(l == -1) {
        dpush(0, &st);
        push(-1, &st);
        RETURN(st, rst);
    }
    off64_t size = lseek64(fid, 0, SEEK_END);
    if(size == -1) {
        dpush(0, &st);
        push(-1, &st);
        RETURN(st, rst);
    }
    lseek64(fid, l, SEEK_SET);
    udpush(size, &st);
    push(0, &st);
    RETURN(st, rst);
}
