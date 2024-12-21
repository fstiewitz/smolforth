#include<config.h>
#include<plt.h>

#if CELL_WIDTH == 64
#ifndef SF_HAS_FREESTANDING

#include<sys/mman.h>
#include<stdio.h>
#include<stdarg.h>
#include "asmgen_riscv.h"

#include <out.h>
#ifndef sf_FORTH_end
#define sf_FORTH_end CORE_last
#define SF_WL_EXPORT_COUNT 1
#define SF_WL_EXPORTED &sf_FORTH_end
#endif

extern ucell CORE_last;

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
        int32_t y = (v - (ucell) &plt->instrs[0]);
        uint32_t lower = (y << 20) >> 20;
        uint32_t upper = ((y - lower) >> 12);
        asmgen_AUIPC(T6, upper, &h);
        asmgen_LX(T6, T6, lower, &h);
        asmgen_JALR(X0, T6, 0, &h);
        asmgen_ADDI(X0, X0, 0, &h);
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
        if(code_got_start[i].addr == addr) return code_got_start + i;
    }
    fprintf(stderr, "could not find GOT entry for address %lx\r\n", addr);
    return addr;
}

ucell count_got(int count, ...) {
    va_list va;
    va_start(va, count);
    ucell word_count = 0;
    code_got_count = 0;
    for(int i = 0; i < count; ++i) {
        void** f = va_arg(va, void**);
        while(f) {
            ++word_count;
            char fl = ((char*)f)[-1];
            if(0 != (fl & (W_EXEC|W_RUNTIME))) {
                if(f[1]) {
                    ++code_got_count;
                }
            }
            f = *f;
        }
    }
    va_end(va);
    return word_count;
}

void import_got_words(int count, ...) {
    va_list va;
    va_start(va, count);
    int j = 0;
    for(int i = 0; i < count; ++i) {
        void** f = va_arg(va, void**);
        while(f) {
            code_got_start[j++].addr = f;
            f = *f;
        }
    }
    va_end(va);
}

void import_got_body(int word_count, int count, ...) {
    va_list va;
    va_start(va, count);
    int j = 0;
    for(int i = 0; i < count; ++i) {
        void** f = va_arg(va, void**);
        while(f) {
            code_got_start[word_count + (j++)].addr = to_body(f);
            f = *f;
        }
    }
    va_end(va);
}

void import_got_exec(int j, int count, ...) {
    va_list va;
    va_start(va, count);
    for(int i = 0; i < count; ++i) {
        void** f = va_arg(va, void**);
        while(f) {
            char fl = ((char*)f)[-1];
            if(0 != (fl & (W_EXEC|W_RUNTIME))) {
                if(f[1]) {
                    code_got_start[j++].addr = f[1];
                }
            }
            f = *f;
        }
    }
    va_end(va);
}

ucell import_plt(ucell code_size) {
    ucell word_count = count_got(SF_WL_EXPORT_COUNT, SF_WL_EXPORTED);
    code_plt_count = code_got_count + word_count;
    code_got_count += 2 * word_count;
    code_size += code_got_count * sizeof(struct got_t);
    code_size += code_plt_count * sizeof(struct plt_t);
    code_got_start = mmap(0, code_size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if(code_got_start == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }
    sf_header.active_section->start = code_got_start;
    sf_header.active_section->here = code_got_start + code_got_count * sizeof(struct got_t) + code_plt_count * sizeof(struct plt_t);
    sf_header.active_section->gate = sf_header.active_section->start;

    import_got_words(SF_WL_EXPORT_COUNT, SF_WL_EXPORTED);
    import_got_body(word_count, SF_WL_EXPORT_COUNT, SF_WL_EXPORTED);
    import_got_exec(2 * word_count, SF_WL_EXPORT_COUNT, SF_WL_EXPORTED);
    //for(ucell i = 0; i < code_got_count; ++i) {
    //    fprintf(stderr, "-%li %li %li %x\n", i, code_got_count, word_count, code_got_start[i].addr);
    //}
    init_plt();
    return code_size;
}
#endif
#endif
