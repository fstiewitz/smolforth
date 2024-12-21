#include<config.h>
#include "../asmgen_x86_64.h"

SFWRAPFUN(AHEAD)

udcell AHEAD_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    upush((ucell)sf_header.active_section->here, &st);
    upush(0, &st);
    upush(0, &st);
    upush(0, &st);

    asmgen_JMP_REL32(0, &sf_header.active_section->here);

    RETURN(st, rst);
}
