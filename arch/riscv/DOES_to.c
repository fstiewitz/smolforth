#include<config.h>
#include "asmgen_riscv.h"

SFWRAPFUN(DOES_to)

udcell DOES_to_impl_c(char* st, char* rst) {
    asmgen_ADDI(S1, S1, -(int) sizeof(cell), &sf_header.cdata->here);
    asmgen_LX(RA, S1, 0, &sf_header.cdata->here);
    asmgen_JALR(X0, RA, 0, &sf_header.cdata->here);
    sf_header.compiler_status = (ucell)sf_header.cdata->here;
    asmgen_SX(RA, S1, 0, &sf_header.cdata->here);
    asmgen_ADDI(S1, S1, sizeof(cell), &sf_header.cdata->here);
    RETURN(st, rst);
}

__attribute__((naked))
udcell SYS_DOES_to_impl(char* st, char* rst) {
    __asm__ volatile (
        "mv a0, s0\n"
        "mv a1, s1\n"
        "mv a3, ra\n"
        "la a2, does_do_impl_c\n"
        "tail sf_to_c\n"
    );
}

udcell does_do_impl_c(char* st, char* rst, void* f, uint32_t *ra) {
    ucell *w = *(ucell**)wl_search_order[WL_SO_MAX-1];
    ++ra;
    while(*ra != 0x00008067) {
        ++ra;
    }
    ++ra;
    w[1] = (ucell)ra;
    RETURN(st, rst);
}
