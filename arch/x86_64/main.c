#include<config.h>
#include<plt.h>

#include<assert.h>
#include<fcntl.h>
#include<stdlib.h>
#include<stdio.h>
#include<unistd.h>
#include<termios.h>
#include<string.h>

__attribute__((aligned(32)))
cell stsp[1024];

#include "out.h"
#ifndef sf_FORTH_end
#define sf_FORTH_end CORE_last
#endif

extern ucell CORE_last;
extern ucell FORTH;
extern ucell FORTH$QUIT_CAUGHT;

char** sf_argv;
int sf_argc;

DECLARE(FORTH$body$QUIT);

#include<sys/mman.h>

int main(int argc, char** argv) {
    sf_argv = argv;
    sf_argc = argc;
    for(int i = 0; i < argc; ++i) {
        if(strcmp(sf_argv[0], "--") == 0) {
            ++sf_argv;
            --sf_argc;
            break;
        }
        ++sf_argv;
        --sf_argc;
    }
    sf_header.base = 10;
    sf_header.active_section = &sf_header.code;
    sf_header.active_section->flags = SECTION_CDATA | SECTION_IDATA | SECTION_UDATA;
    sf_header.cdata = &sf_header.code;
    sf_header.idata = &sf_header.code;
    sf_header.udata = &sf_header.code;
    sf_header.wdata = 0;
    sf_header.uidata = &sf_header.code;
    sf_header.icdata = &sf_header.code;
    sf_header.stack_size = 1024;
    cell code_size = 16 * 1024 * 1024;
    ucell word_count = 0;
    code_got_count = 0;
    void** f = (void**)&sf_FORTH_end;
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

    f = (void**)&sf_FORTH_end;
    for(ucell i = 0; i < word_count; ++i) {
        code_got_start[i].addr = (ucell)f;
        f = *f;
    }
    f = (void**)&sf_FORTH_end;
    for(ucell i = 0; i < word_count; ++i) {
        code_got_start[word_count + i].addr = (ucell)to_body(f);
        f = *f;
    }
    {
        f = (void**)&sf_FORTH_end;
        int i = 2 * word_count;
        while(f) {
            char fl = ((char*)f)[-1];
            if(0 != (fl & (W_EXEC|W_RUNTIME))) {
                if(f[1]) {
                    code_got_start[i++].addr = (ucell)f[1];
                }
            }
            f = *f;
        }
    }
    //for(ucell i = 0; i < code_got_count; ++i) {
    //    fprintf(stderr, "-%li %li %li %lx\n", i, code_got_count, word_count, code_got_start[i].addr);
    //}
    init_plt();

    sf_header.active_section->end = sf_header.active_section->start + code_size;
    sf_header.code.word = 0;
    fprintf(stderr, "code mapping at %p (size %li)\n", sf_header.active_section->start, code_size);

    struct termios pterm0;
    struct termios pterm1;
    struct termios nterm;
    tcgetattr(0, &pterm0);
    tcgetattr(1, &pterm1);
    cfmakeraw(&nterm);
    nterm.c_iflag = ICRNL;
    tcsetattr(0, TCSANOW, &nterm);
    tcsetattr(1, TCSANOW, &nterm);

    wl_search_order[WL_SO_MAX-1] = wl_search_order[0];
    (&FORTH)[2] = (ucell)&sf_FORTH_end;
    sf_header.stack_ptr = stsp;
    sf_header.return_stack_ptr = (ucell*)alloca(2*4096);
    ucell* c = sf_header.return_stack_ptr;
    sf_header.return_stack_ptr = (void*)(((ucell)sf_header.return_stack_ptr + 2*4096) & -32lu);
    sf_header.return_stack_size = (ucell)sf_header.return_stack_ptr - ((ucell)c & -32lu);
    int rc = 0;
    for(int i = 1; i < argc; ++i) {
        int f;
        if(strcmp(argv[i], "--") == 0) break;
        if(strcmp(argv[i], "-") == 0) {
            f = 0;
        } else {
            f = open(argv[i], O_RDONLY);
        }
        if(f == -1) {
            perror("open");
            exit(1);
        }
        sf_header.source_id = f;
        char* st = (char*)sf_header.stack_ptr;
        char* rst = (char*)sf_header.return_stack_ptr;
        union ret r;
        r.r = c_to_sf(st, rst, FORTH$body$QUIT);
        st = (void*)r.a0;
        rst = (void*)r.a1;
        if(f) close(f);
        if(sf_header.errno) {
            rc = sf_header.errno;
            if(!(&FORTH$QUIT_CAUGHT)[2]) {
                if(-13 == sf_header.errno) {
                    printf("UNKNOWN WORD ");
                    fwrite(sf_header.err_str, sf_header.err_size, 1, stdout);
                    printf("\r\n");
                }
            }
            break;
        }
    }

    tcsetattr(0, TCSANOW, &pterm0);
    tcsetattr(1, TCSANOW, &pterm1);

    munmap(sf_header.active_section->start, sf_header.active_section->end - sf_header.active_section->start);
    return rc;
}
