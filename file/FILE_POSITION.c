#define _LARGEFILE64_SOURCE
#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(FILE_POSITION)

udcell FILE_POSITION_impl_c(char* st, char* rst) {
    cell fid = pop(&st);
    off64_t l = lseek64(fid, 0, SEEK_CUR);
    if(l == -1) {
        dpush(0, &st);
        push(-1, &st);
    } else {
        dpush(l, &st);
        push(0, &st);
    }
    RETURN(st, rst);
}
