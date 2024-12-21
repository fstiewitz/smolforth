#include<config.h>
#include<plt.h>

#include<stdio.h>
#include "asmgen_riscv.h"

void c_store(signed reg, ucell v) {
#if CELL_WIDTH == 64
    ucell dtest = ((cell)v) >> 32;
    if(dtest != 0 && dtest != -1) {
        if(0 != (v & 0xffffffff)) {
            c_store(reg + 1, v >> 32);
            asmgen_ADDI(T0, X0, 32, &sf_header.cdata->here);
            asmgen_SLL(reg + 1, reg + 1, T0, &sf_header.cdata->here);
            c_store(reg, v & 0xffffffff);
            asmgen_SLL(reg, reg, T0, &sf_header.cdata->here);
            asmgen_SRL(reg, reg, T0, &sf_header.cdata->here);
            asmgen_OR(reg, reg, reg + 1, &sf_header.cdata->here);
        } else {
            c_store(reg, v >> 32);
            asmgen_ADDI(T0, X0, 32, &sf_header.cdata->here);
            asmgen_SLL(reg, reg, T0, &sf_header.cdata->here);
        }
        return;
    }
#endif
    int32_t x = (int32_t) v;
    uint32_t lower = (x << 20) >> 20;
    uint32_t upper = ((x - lower) >> 12);
    if (upper != 0 && upper != -1) {
        asmgen_LUI(reg, upper, &sf_header.cdata->here);
        if(lower) {
#if CELL_WIDTH == 64
            asmgen_ADDIW(reg, reg, lower, &sf_header.cdata->here);
#else
            asmgen_ADDI(reg, reg, lower, &sf_header.cdata->here);
#endif
        }
    } else {
#if CELL_WIDTH == 64
        asmgen_ADDIW(reg, X0, lower, &sf_header.cdata->here);
#else
        asmgen_ADDI(reg, X0, lower, &sf_header.cdata->here);
#endif
    }
#if CELL_WIDTH == 64
    if((v >> 32) == 0) {
        asmgen_ADDI(T0, X0, 32, &sf_header.cdata->here);
        asmgen_SLL(reg, reg, T0, &sf_header.cdata->here);
        asmgen_SRL(reg, reg, T0, &sf_header.cdata->here);
    }
#endif
}


SFWRAPFUN(SYS_COMPILE_CONSTANT)

udcell SYS_COMPILE_CONSTANT_impl_c(char* st, char* rst) {
    c_store(A2, upop(&st));
    pop(&st);
    asmgen_SX(A2, S0, 0, &sf_header.cdata->here);
    asmgen_ADDI(S0, S0, sizeof(cell), &sf_header.cdata->here);
    RETURN(st, rst);
}

SFWRAPFUN(SYS_COMPILE_ADDR)

udcell SYS_COMPILE_ADDR_impl_c(char* st, char* rst) {
    ucell v = pop(&st);
    ucell o = pop(&st);
#if CELL_WIDTH == 64
#ifndef SF_HAS_FREESTANDING
    ucell dtest = (cell)(v - (ucell)sf_header.cdata->here) >> 32;
    if(dtest != 0 && dtest != -1) {
        ucell g = find_got(v);
        if(g != -1) {
            int32_t y = (g - (ucell) sf_header.cdata->here);
            uint32_t lower = (y << 20) >> 20;
            uint32_t upper = ((y - lower) >> 12);
            asmgen_AUIPC(A2, upper, &sf_header.cdata->here);
            asmgen_LD(A2, A2, lower, &sf_header.cdata->here);
            sf_header.compiler_status = 1;
            asmgen_SX(A2, S0, 0, &sf_header.cdata->here);
            asmgen_ADDI(S0, S0, sizeof(cell), &sf_header.cdata->here);
            RETURN(st, rst);
        }
        fprintf(stderr, "ADDR OUT OF RANGE %lx -> %lx\r\n", sf_header.cdata->here, v);
    }
    assert(dtest == 0 || dtest == -1);
#endif
#endif
    int32_t y = (v - (ucell) sf_header.cdata->here);
    uint32_t lower = (y << 20) >> 20;
    uint32_t upper = ((y - lower) >> 12);
    asmgen_AUIPC(A2, upper, &sf_header.cdata->here);
    if(lower) {
        asmgen_ADDI(A2, A2, lower, &sf_header.cdata->here);
        sf_header.compiler_status = 0;
    } else {
        sf_header.compiler_status = 3;
    }
    asmgen_SX(A2, S0, 0, &sf_header.cdata->here);
    asmgen_ADDI(S0, S0, sizeof(cell), &sf_header.cdata->here);
    RETURN(st, rst);
}

SFWRAPFUN(SYS_COMPILE_EXECUTE)

udcell SYS_COMPILE_EXECUTE_impl_c(char* st, char* rst) {
    ucell v = pop(&st);
    pop(&st);
#if CELL_WIDTH == 64
#ifndef SF_HAS_FREESTANDING
    ucell dtest = (cell)(v - (ucell)sf_header.cdata->here) >> 32;
    if(dtest != 0 && dtest != -1) {
        v = find_plt(v);
    }
    dtest = (cell)(v - (ucell)sf_header.cdata->here) >> 32;
    if(dtest != 0 && dtest != -1) {
        fprintf(stderr, "JUMP OUT OF RANGE %lx -> %lx\r\n", sf_header.cdata->here, v);
    }
    assert(dtest == 0 || dtest == -1);
#endif
#endif
    int32_t y = (v - (ucell) sf_header.cdata->here);
    if(y < -0x100000 || y > 0x100000 || v < sf_header.cdata->gate || v >= sf_header.cdata->end) {
        uint32_t lower = (y << 20) >> 20;
        uint32_t upper = ((y - lower) >> 12);
        asmgen_AUIPC(RA, upper, &sf_header.cdata->here);
        asmgen_JALR(RA, RA, lower, &sf_header.cdata->here);
        sf_header.compiler_status = 0;
    } else {
        asmgen_JAL(RA, y, &sf_header.cdata->here);
        sf_header.compiler_status = 1;
    }
    RETURN(st, rst);
}

#ifdef SF_HAS_FLOAT

SFWRAPFUN(SYS_COMPILE_FCONSTANT)

#include <float/float.h>

void c_storef(signed reg, fcell v) {
    ucell f = *(ucell*)&v;
    c_store(reg, f);
}


udcell SYS_COMPILE_FCONSTANT_impl_c(char* st, char* rst) {
    c_storef(A2, fpop());
    pop(&st);
    asmgen_SX(A2, S2, 0, &sf_header.cdata->here);
    asmgen_ADDI(S2, S2, sizeof(fcell), &sf_header.cdata->here);
    RETURN(st, rst);
}

#endif
