#pragma once

#include<config.h>

struct got_t {
    ucell addr;
};

struct plt_t {
    union {
        uint32_t instrs[4];
        struct {
            uint32_t auipc;
            uint32_t lx;
            uint32_t jalr;
            uint32_t nop;
        };
    };
};

extern struct got_t *code_got_start;
extern ucell code_got_count;
extern ucell code_plt_count;

ucell import_plt(ucell code_size);
ucell find_plt(ucell addr);
ucell find_got(ucell addr);
