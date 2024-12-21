#include<config.h>
#include<alloca.h>
#include<string.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(DELETE_FILE)

udcell DELETE_FILE_impl_c(char* st, char* rst) {
    cell u = pop(&st);
    char* addr = (void*)upop(&st);
    if(u <= 0) {
        push(-1, &st);
    } else {
        char* f = alloca(u + 1);
        memcpy(f, addr, u);
        f[u] = 0;
        if(-1 == unlink(f)) {
            push(-1, &st);
        } else {
            push(0, &st);
        }
    }
    RETURN(st, rst);
}
