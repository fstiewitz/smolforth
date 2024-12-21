#ifndef SMOLFORTH_CONFIG_LOCAL_H
#define SMOLFORTH_CONFIG_LOCAL_H

#define SFWRAPFUN(X) __attribute__((naked)) \
udcell X##_impl(char* st, char* rst) { \
    __asm__ volatile ( \
        "mv a0, s0\n" \
        "mv a1, s1\n" \
        "la a2, " #X "_impl_c\n" \
        "tail sf_to_c\n" \
    ); \
}

#define SFWRAPBODY(X) __attribute__((naked)) \
udcell body$##X(char* st, char* rst) { \
    __asm__ volatile ( \
        "mv a0, s0\n" \
        "mv a1, s1\n" \
        "la a2, " #X "_impl_c\n" \
        "tail sf_to_c\n" \
    ); \
}

typedef int32_t cell;
typedef uint32_t ucell;
typedef int64_t dcell;
typedef uint64_t udcell;
typedef float fcell;

#define CELL_MAX INT32_MAX
#define UCELL_MAX UINT32_MAX
#define FCELL_MAX FLT_MAX

#define CELL_WIDTH 32
#define DCELL_WIDTH 64
#define FCELL_WIDTH 32

#define asmgen_LX asmgen_LW
#define asmgen_SX asmgen_SW

extern char** sf_argv;
extern int sf_argc;

#endif //SMOLFORTH_CONFIG_LOCAL_H
