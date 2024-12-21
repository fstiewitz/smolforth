#include<config.h>
#include "../asmgen_riscv.h"

SFWRAPFUN(EXIT)

udcell EXIT_impl_c(char* st, char* rst) {
    asmgen_ADDI(S1, S1, -(int) sizeof(cell), &sf_header.active_section->here);
    asmgen_LX(RA, S1, 0, &sf_header.active_section->here);
    asmgen_JALR(X0, RA, 0, &sf_header.active_section->here);
    RETURN(st, rst);
}
