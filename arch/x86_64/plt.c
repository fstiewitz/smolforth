#include<config.h>
#include<plt.h>
#include<stdio.h>

#include "asmgen_x86_64.h"

struct got_t *code_got_start;
ucell code_got_count;
ucell code_plt_count;
struct plt_t *code_plt_start;

void init_plt() {
    struct plt_t *plt = (struct plt_t*)(code_got_start + code_got_count);
    code_plt_start = plt;
    ucell word_count = code_got_count - code_plt_count;
    for(ucell i = 0; i < code_plt_count; ++i) {
        char* h = (char*)&plt->instrs[0];
        ucell v = (ucell)(code_got_start + word_count + i);
        asmgen_MOV_TAKE_REL32(RBX, v, &h);
        asmgen_JMP(RBX, &h);
        ++plt;
    }
}

ucell find_plt(ucell addr) {
    ucell word_count = code_got_count - code_plt_count;
    for(ucell i = 0; i < code_plt_count; ++i) {
        if(code_got_start[word_count + i].addr == addr) return code_plt_start + i;
    }
    fprintf(stderr, "could not find PLT entry for address %lx\r\n", addr);
    return addr;
}

ucell find_got(ucell addr) {
    for(ucell i = 0; i < code_got_count; ++i) {
        if(code_got_start[i].addr == addr) return (ucell)(code_got_start + i);
    }
    fprintf(stderr, "could not find GOT entry for address %lx\r\n", addr);
    return addr;
}
