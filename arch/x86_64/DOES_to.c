#include<config.h>
#include "asmgen_x86_64.h"

__attribute__((naked))
udcell DOES_to_impl(char* st, char* rst) {
    __asm__ volatile (
        "movq %r15, %rdi\n"
        "movq %rsp, %rsi\n"
        "leaq DOES_to_impl_c(%rip), %rdx\n"
        "jmp sf_to_c\n"
    );
}

udcell DOES_to_impl_c(char* st, char* rst) {
    asmgen_RET(&sf_header.cdata->here);
    sf_header.compiler_status = (ucell)sf_header.cdata->here;
    RETURN(st, rst);
}

__attribute__((naked))
udcell SYS_DOES_to_impl(char* st, char* rst) {
    __asm__ volatile (
        "movq %r15, %rdi\n"
        "movq %rsp, %rsi\n"
        "movq (%rsp), %rcx\n"
        "leaq does_do_impl_c(%rip), %rdx\n"
        "jmp sf_to_c\n"
    );
}

udcell does_do_impl_c(char* st, char* rst, void* f, unsigned char *ra) {
    ucell *w = *(ucell**)wl_search_order[WL_SO_MAX - 1];
    while(*ra != 0xC3) {
        ++ra;
    }
    ++ra;
    w[1] = (ucell)ra;
    RETURN(st, rst);
}
