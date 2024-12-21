#include<config.h>
#include<alloca.h>
#include<string.h>
#include<fcntl.h>

SFWRAPFUN(OPEN_FILE)

udcell OPEN_FILE_impl_c(char* st, char* rst) {
    cell fam = pop(&st);
    cell u = pop(&st);
    char* addr = (void*)upop(&st);
    if(u <= 0) {
        push(0, &st);
        push(-1, &st);
    } else {
        char* f = alloca(u + 1);
        memcpy(f, addr, u);
        f[u] = 0;
        int flags = 0;
        int mode = (fam & 07) << 6;
        if(mode == 0400) {
            flags = O_RDONLY;
        } else if(mode == 0200) {
            flags = O_WRONLY;
        } else if(mode) {
            flags = O_RDWR;
        } else {
            push(0, &st);
            push(-1, &st);
            RETURN(st, rst);
        }
        int fd = open(f, flags);
        if(fd == -1) {
            push(0, &st);
            push(-1, &st);
        } else {
            push(fd, &st);
            push(0, &st);
        }
    }
    RETURN(st, rst);
}
