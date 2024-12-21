#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(WRITE_FILE)

udcell WRITE_FILE_impl_c(char* st, char* rst) {
    cell fid = pop(&st);
    cell u = pop(&st);
    char* addr = (void*)upop(&st);
    if(u <= 0) {
        push(0, &st);
    } else {
        while(u > 0) {
            ssize_t r = write(fid, addr, u);
            if(r == -1) {
                push(-1, &st);
                RETURN(st, rst);
            } else {
                u -= r;
                addr += r;
            }
        }
        push(0, &st);
    }
    RETURN(st, rst);
}
