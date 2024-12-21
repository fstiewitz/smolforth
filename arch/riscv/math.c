#include<config.h>

__attribute__((naked))
udcell number_sign_c_impl(char* st, char* rst) {
    __asm__ volatile (
        "mv a0, s0\n"
        "mv a1, s1\n"
        "la a2, number_sign_impl_c\n"
        "tail sf_to_c\n"
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
