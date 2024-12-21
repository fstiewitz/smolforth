#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(READ_FILE)

udcell READ_FILE_impl_c(char* st, char* rst) {
    cell fid = pop(&st);
    cell u = pop(&st);
    char* addr = (void*)upop(&st);
    if(u <= 0) {
        push(0, &st);
        push(-1, &st);
    } else {
        ssize_t r = read(fid, addr, u);
        if(r == -1) {
            push(0, &st);
            push(-1, &st);
        } else {
            push(r, &st);
            push(0, &st);
        }
    }
    RETURN(st, rst);
}
