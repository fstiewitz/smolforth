#include<config.h>

__attribute__((naked))
udcell number_sign_c_impl(char* st, char* rst) {
    __asm__ volatile (
        "movq %r15, %rdi\n"
        "movq %rsp, %rsi\n"
        "leaq number_sign_impl_c(%rip), %rdx\n"
        "jmp sf_to_c\n"
    );
}

udcell number_sign_impl_c(char* st, char* rst) {
    udcell v = udpop(&st);
    udcell q = v / sf_header.base;
    ucell r = (ucell) (v % sf_header.base);
    udpush(q, &st);
    if (r < 10) {
        push('0' + r, &st);
    } else if (r < 37) {
        push('A' + (r - 10), &st);
    } else {
        push('#', &st);
    }
    RETURN(st, rst);
}
