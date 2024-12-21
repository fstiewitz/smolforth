#include<config.h>
#include "../asmgen_x86_64.h"

SFWRAPFUN(UNTIL)

udcell UNTIL_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    st -= 3 * sizeof(ucell);
    char* addr = (void*)upop(&st);
    asmgen_ADD_IMM(R15, -(int)sizeof(cell), &sf_header.active_section->here);
    asmgen_MOVQ_TAKE(R15, RBX, &sf_header.active_section->here);
    asmgen_BEQ_IMM(RBX, 0, addr - sf_header.active_section->here, &sf_header.active_section->here);
    RETURN(st, rst);
}
