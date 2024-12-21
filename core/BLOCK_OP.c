#include<config.h>
#include <stdio.h>
#include<string.h>

SFWRAPFUN(BLOCK_OP)

udcell BLOCK_OP_impl_c(char* st, char* rst) {
    cell op = pop(&st);
    void* addr = (void*)upop(&st);
    cell n = pop(&st);
    char buf[64];
    snprintf(buf, 64, "block_%i.bin", n);
    if(op) { // write
        FILE* fd = fopen(buf, "w");
        if(!fd) {
            RETURN(st, rst);
        }
        if(1 != fwrite(addr, 1024, 1, fd)) {
            fclose(fd);
            RETURN(st, rst);
        }
        fclose(fd);
    } else { // read
        FILE* fd = fopen(buf, "r");
        if(!fd) {
            RETURN(st, rst);
        }
        if(1 != fread(addr, 1024, 1, fd)) {
            fclose(fd);
            RETURN(st, rst);
        }
        fclose(fd);
    }
    RETURN(st, rst);
}
