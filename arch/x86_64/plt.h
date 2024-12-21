#pragma once
#include<config.h>

struct got_t {
    ucell addr;
};

struct plt_t {
    char instrs[9];
};

extern struct got_t *code_got_start;
extern ucell code_got_count;
extern ucell code_plt_count;
void init_plt();
ucell find_got(ucell addr);
ucell find_plt(ucell addr);
