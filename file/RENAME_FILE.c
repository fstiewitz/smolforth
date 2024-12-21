#include<config.h>
#include<alloca.h>
#include<string.h>
#include<fcntl.h>
#include<stdio.h>

SFWRAPFUN(RENAME_FILE)

udcell RENAME_FILE_impl_c(char* st, char* rst) {
    cell u1 = pop(&st);
    char* addr1 = (void*)upop(&st);
    cell u0 = pop(&st);
    char* addr0 = (void*)upop(&st);
    if(u0 <= 0 || u1 <= 0) {
        push(-1, &st);
    } else {
        char* f1 = alloca(u1 + 1);
        memcpy(f1, addr1, u1);
        f1[u1] = 0;
        char* f0 = alloca(u0 + 1);
        memcpy(f0, addr0, u0);
        f0[u0] = 0;
        if(rename(f0, f1)) {
            push(-1, &st);
        } else {
            push(0, &st);
        }
    }
    RETURN(st, rst);
}
