#include<config.h>
#include "../asmgen_riscv.h"

SFWRAPFUN(AHEAD)

udcell AHEAD_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    upush((ucell)sf_header.active_section->here, &st);
    upush(0, &st);
    upush(0, &st);
    upush(0, &st);

    asmgen_JAL(X0, 0, &sf_header.active_section->here);
    RETURN(st, rst);
}
