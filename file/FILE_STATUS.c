#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<string.h>
#include<unistd.h>
#include<sys/stat.h>

SFWRAPFUN(FILE_STATUS)

udcell FILE_STATUS_impl_c(char* st, char* rst) {
    cell u = pop(&st);
    char* addr = (void*)upop(&st);
    if(u <= 0) {
        push(0, &st);
        push(-1, &st);
    } else {
        char* f = alloca(u + 1);
        memcpy(f, addr, u);
        f[u] = 0;
        struct stat s;
        if(stat(f, &s) == -1) {
            push(0, &st);
            push(-1, &st);
        } else {
            push(s.st_mode, &st);
            push(0, &st);
        }
    }
    RETURN(st, rst);
}
