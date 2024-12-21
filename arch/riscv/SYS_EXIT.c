

#include<config.h>

__attribute__((naked))
udcell SYS_EXIT_impl(char* st, char* rst) {
    __asm__ volatile (
        "mv a0, s0\n"
        "mv a1, s1\n"
        "la a2, SYS_EXIT_impl_c\n"
        "tail sf_to_c\n"
    );
}

udcell SYS_EXIT_impl_c(char* st, char* rst) {
    print_stacks(st, rst);
    rst = (char*)(sf_header.return_stack_ptr + 1);
    sf_header.errno = 1;
    RETURN(st, rst);
}

