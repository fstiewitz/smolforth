#include<config.h>
#include "../asmgen_x86_64.h"

SFWRAPFUN(AGAIN)


udcell AGAIN_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    st -= 3 * sizeof(ucell);
    char* addr = (void*)upop(&st);
    asmgen_JMP_REL32(addr - (char*)sf_header.active_section->here, &sf_header.active_section->here);
    RETURN(st, rst);
}
