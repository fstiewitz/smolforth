#include<config.h>
#include<alloca.h>
#include<fcntl.h>
#include<unistd.h>

SFWRAPFUN(READ_LINE)

udcell READ_LINE_impl_c(char* st, char* rst) {
    cell fid = pop(&st);
    cell u = pop(&st);
    char* addr = (void*)upop(&st);
    if(u <= 0) {
        push(0, &st);
        push(-1, &st);
        push(0, &st);
    } else {
        int l = 0;
        while(u > 0) {
            char c;
            int r = read(fid, &c, 1);
            if(r == 1) {
                if(c == '\r') {
                    r = read(fid, &c, 1);
                    break;
                }
                if(c == '\n') {
                    break;
                }
                *(addr++) = c;
                --u;
                ++l;
            } else if(r == 0) {
                if(l == 0) {
                    push(0, &st);
                    push(0, &st);
                    push(0, &st);
                    RETURN(st, rst);
                }
                break;
            } else {
                push(0, &st);
                push(0, &st);
                push(-1, &st);
                RETURN(st, rst);
            }
        }
        push(l, &st);
        push(-1, &st);
        push(0, &st);
    }
    RETURN(st, rst);
}
