#include<config.h>
#include "../asmgen_riscv.h"

SFWRAPFUN(IF)

void asmgen_BEQ_OR_JAL_NOP(int rs1, int rs2, uint32_t imm, char **p) {
	if((-1 == (int32_t)imm >> 12) || (0 == (int32_t)imm >> 12)) {
        asmgen_BEQ(rs1, rs2, imm, p);
        asmgen_ADDI(X0, X0, 0, p);
    } else {
        char *s = *p;
        asmgen_BNE(rs1, rs2, 0, p);
        asmgen_JAL(X0, imm - (*p - s), p);
        asmgen_BNE(rs1, rs2, *p - s, &s);
    }
}

void asmgen_BEQ_OR_JAL(int rs1, int rs2, uint32_t imm, char **p) {
	if((-1 == (int32_t)imm >> 12) || (0 == (int32_t)imm >> 12)) {
        asmgen_BEQ(rs1, rs2, imm, p);
    } else {
        char *s = *p;
        asmgen_BNE(rs1, rs2, 0, p);
        asmgen_JAL(X0, imm - (*p - s), p);
        asmgen_BNE(rs1, rs2, *p - s, &s);
    }
}

udcell IF_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    asmgen_ADDI(S0, S0, -sizeof(cell), &sf_header.active_section->here);
    asmgen_LX(A2, S0, 0, &sf_header.active_section->here);

    upush((ucell)sf_header.active_section->here, &st);
    upush(A2, &st);
    upush(X0, &st);
    upush((ucell)asmgen_BEQ_OR_JAL, &st);

    asmgen_BEQ_OR_JAL_NOP(A2, X0, 0, &sf_header.active_section->here);
    RETURN(st, rst);
}
