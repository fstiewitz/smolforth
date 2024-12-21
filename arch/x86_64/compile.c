#include<config.h>

#include<stdio.h>

#include <plt.h>

#include "asmgen_x86_64.h"
#include "config-local.h"

#include<assert.h>

void c_store(signed reg, ucell v) {
    asmgen_MOV_IMM64(reg, v, &sf_header.cdata->here);
}

SFWRAPFUN(SYS_COMPILE_CONSTANT)

udcell SYS_COMPILE_CONSTANT_impl_c(char* st, char* rst) {
    c_store(RBX, pop(&st));
    pop(&st);
    asmgen_MOVQ_PUT(RBX, R15, &sf_header.cdata->here);
    asmgen_ADD_IMM(R15, sizeof(cell), &sf_header.cdata->here);
    RETURN(st, rst);
}

SFWRAPFUN(SYS_COMPILE_ADDR)

udcell SYS_COMPILE_ADDR_impl_c(char* st, char* rst) {
    intptr_t v = upop(&st);
    pop(&st);
#ifndef SF_HAS_FREESTANDING
    cell dtest = ((cell)(v - (ucell)sf_header.cdata->here)) >> 32;
    if(dtest != 0 && dtest != -1) {
        ucell g = find_got(v);
        if(g != v) {
            dtest = ((cell)(g - (ucell)sf_header.cdata->here)) >> 32;
            if(dtest != 0 && dtest != -1) {
                fprintf(stderr, "GOT OUT OF RANGE %lx -> %lx -> %lx\r\n", (ucell)sf_header.cdata->here, g, v);
                exit(1);
            }
            asmgen_MOV_TAKE_REL32(RBX, g, &sf_header.cdata->here);
            sf_header.compiler_status = 0;
            asmgen_MOVQ_PUT(RBX, R15, &sf_header.cdata->here);
            asmgen_ADD_IMM(R15, sizeof(cell), &sf_header.cdata->here);
            RETURN(st, rst);
        }
        fprintf(stderr, "ADDR OUT OF RANGE %lx -> %lx\r\n", sf_header.cdata->here, v);
    }
    assert(dtest == 0 || dtest == -1);
#endif
    asmgen_LEA_REL32(RBX, v, &sf_header.cdata->here);
    sf_header.compiler_status = 1;
    asmgen_MOVQ_PUT(RBX, R15, &sf_header.cdata->here);
    asmgen_ADD_IMM(R15, sizeof(cell), &sf_header.cdata->here);
    RETURN(st, rst);
}

SFWRAPFUN(SYS_COMPILE_EXECUTE)

udcell SYS_COMPILE_EXECUTE_impl_c(char* st, char* rst) {
    ucell v = pop(&st);
    pop(&st);
#if CELL_WIDTH == 64
#ifndef SF_HAS_FREESTANDING
    int32_t dtest = ((cell)(v - (ucell)sf_header.cdata->here)) >> 32;
    if(dtest != 0 && dtest != -1) {
        v = find_plt(v);
    }
    dtest = (cell)(v - (ucell)sf_header.cdata->here) >> 32;
    if(dtest != 0 && dtest != -1) {
        fprintf(stderr, "JUMP OUT OF RANGE %lx -> %lx\r\n", (ucell)sf_header.cdata->here, v);
    }
    assert(dtest == 0 || dtest == -1);
#endif
    int32_t y = (v - (ucell) sf_header.cdata->here);
    asmgen_CALL_REL32(y, &sf_header.cdata->here);
    sf_header.compiler_status = 0;
#else
    int32_t y = (v - (ucell) sf_header.cdata->here);
    asmgen_CALL_REL32(y, &sf_header.cdata->here);
    sf_header.compiler_status = 0;
#endif
    RETURN(st, rst);
}

#ifdef SF_HAS_FLOAT

SFWRAPFUN(SYS_COMPILE_FCONSTANT)

#include <float/float.h>

void c_storef(signed reg, double v) {
    ucell f = *(ucell*)&v;
    asmgen_MOV_IMM64(reg, f, &sf_header.cdata->here);
}


udcell SYS_COMPILE_FCONSTANT_impl_c(char* st, char* rst) {
    c_storef(RBX, fpop());
    pop(&st);
    asmgen_MOVQ_PUT(RBX, R14, &sf_header.cdata->here);
    asmgen_ADD_IMM(R14, sizeof(double), &sf_header.cdata->here);
    RETURN(st, rst);
}

#endif
