#include<config.h>

#include "../asmgen_x86_64.h"

SFWRAPFUN(IF)

udcell IF_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    asmgen_ADD_IMM(R15, -(int)sizeof(cell), &sf_header.active_section->here);
    asmgen_MOVQ_TAKE(R15, RBX, &sf_header.active_section->here);

    upush((ucell)sf_header.active_section->here, &st);
    upush(0, &st);
    upush(RBX, &st);
    upush((ucell)asmgen_BEQ_IMM, &st);

    asmgen_BEQ_IMM(RBX, 0, 0, &sf_header.active_section->here);
    RETURN(st, rst);
}
