#include<config.h>
#include "../asmgen_riscv.h"

SFWRAPFUN(AGAIN)

udcell AGAIN_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    st -= 3 * sizeof(ucell);
    char* addr = (void*)upop(&st);
    asmgen_JAL(X0, addr - (char*)sf_header.active_section->here, &sf_header.active_section->here);
    RETURN(st, rst);
}
