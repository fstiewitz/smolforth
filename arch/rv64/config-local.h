#ifndef SMOLFORTH_CONFIG_LOCAL_H
#define SMOLFORTH_CONFIG_LOCAL_H

#include<stdint.h>

#define SFWRAPFUN(X) __attribute__((naked)) \
udcell X##_impl(char* st, char* rst) { \
    __asm__ volatile ( \
        "mv a0, s0\n" \
        "mv a1, s1\n" \
        "la a2, " #X "_impl_c\n" \
        "tail sf_to_c\n" \
    ); \
}

#define SFWRAPBODY(WL, X) __attribute__((naked)) \
udcell WL##$body$##X(char* st, char* rst) { \
    __asm__ volatile ( \
        "mv a0, s0\n" \
        "mv a1, s1\n" \
        "la a2, " #X "_impl_c\n" \
        "tail sf_to_c\n" \
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

#define asmgen_LX asmgen_LD
#define asmgen_SX asmgen_SD

extern char** sf_argv;
extern int sf_argc;

#endif //SMOLFORTH_CONFIG_LOCAL_H
