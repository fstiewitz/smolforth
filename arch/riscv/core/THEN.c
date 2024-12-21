#include<config.h>
#include "../asmgen_riscv.h"

SFWRAPFUN(THEN)

udcell THEN_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    void (*cond)(int, int, int, char**) = (void*)upop(&st);
    int reg0 = upop(&st);
    int reg1 = upop(&st);
    char* addr = (void*)upop(&st);
    if(cond) {
        cond(reg0, reg1, sf_header.active_section->here - addr, &addr);
    } else {
        asmgen_JAL(X0, sf_header.active_section->here - addr, &addr);
    }
    RETURN(st, rst);
}