#ifndef SMOLFORTH_CONFIG_LOCAL_H
#define SMOLFORTH_CONFIG_LOCAL_H

#define SFWRAPFUN(X) __attribute__((naked)) \
udcell X##_impl(char* st, char* rst) { \
    __asm__ volatile ( \
        "movq %r15, %rdi\n" \
        "movq %rsp, %rsi\n" \
        "leaq " #X "_impl_c(%rip), %rdx\n" \
        "jmp sf_to_c\n" \
    ); \
}
#define SFWRAPBODY(WL, X) __attribute__((naked)) \
udcell WL##$body$##X(char* st, char* rst) { \
    __asm__ volatile ( \
        "movq %r15, %rdi\n" \
        "movq %rsp, %rsi\n" \
        "leaq " #X "_impl_c(%rip), %rdx\n" \
        "jmp sf_to_c\n" \
    ); \
}

typedef int64_t cell;
typedef uint64_t ucell;
typedef __int128_t dcell;
typedef __uint128_t udcell;
typedef double fcell;

#define CELL_MAX INT64_MAX
#define UCELL_MAX UINT64_MAX
#define FCELL_MAX DBL_MAX

#define CELL_WIDTH 64
#define DCELL_WIDTH 128
#define FCELL_WIDTH 64

extern char** sf_argv;
extern int sf_argc;

#endif //SMOLFORTH_CONFIG_LOCAL_H
