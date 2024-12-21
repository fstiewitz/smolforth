#include<config.h>
#include "../asmgen_riscv.h"

SFWRAPFUN(UNTIL)

void asmgen_BEQ_OR_JAL(int rs1, int rs2, uint32_t imm, char **p);

udcell UNTIL_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    st -= 3 * sizeof(ucell);
    char* addr = (void*)upop(&st);
    asmgen_ADDI(S0, S0, -sizeof(cell), &sf_header.active_section->here);
    asmgen_LX(A2, S0, 0, &sf_header.active_section->here);
    asmgen_BEQ_OR_JAL(A2, X0, addr - sf_header.active_section->here, &sf_header.active_section->here);
    RETURN(st, rst);
}
