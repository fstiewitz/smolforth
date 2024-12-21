#include<config.h>

__attribute__((naked))
udcell SYS_EXIT_impl(char* st, char* rst) {
    __asm__ volatile (
        "movq %r15, %rdi\n"
        "movq %rsp, %rsi\n"
        "leaq SYS_EXIT_impl_c(%rip), %rdx\n"
        "jmp sf_to_c\n"
    );
}

udcell SYS_EXIT_impl_c(char* st, char* rst) {
    print_stacks(st, rst);
    rst = (char*)(sf_header.return_stack_ptr) - 8;
    sf_header.errno = 1;
    RETURN(st, rst);
}

