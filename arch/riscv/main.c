#include<config.h>

#include<plt.h>

#include<assert.h>
#include<fcntl.h>
#include<stdlib.h>
#include<stdio.h>
#include<unistd.h>
#include<string.h>
#include<termios.h>
#include<stdarg.h>

cell stsp[1024];

DECLARE(FORTH$body$QUIT);

#include <out.h>
#ifndef sf_FORTH_end
#define sf_FORTH_end CORE_last
#define SF_WL_EXPORT_COUNT 1
#define SF_WL_EXPORTED &sf_FORTH_end
#endif

extern ucell CORE_last;
extern ucell FORTH;
extern ucell FORTH$QUIT_CAUGHT;

#include<sys/mman.h>

char** sf_argv;
int sf_argc;

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
    wl_search_order[WL_SO_MAX-1] = wl_search_order[0];
    (&FORTH)[2] = (ucell)&sf_FORTH_end;
    cell code_size = 16 * 1024 * 1024;
#if CELL_WIDTH == 64
    code_size = import_plt(code_size);
#else
    sf_header.active_section->start = mmap(0, code_size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if(sf_header.active_section->start == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }
    sf_header.active_section->gate = sf_header.active_section->start;
    sf_header.active_section->here = sf_header.active_section->start;
#endif
    sf_header.active_section->end = sf_header.active_section->start + code_size;
    sf_header.code.word = 0;
    fprintf(stderr, "code mapping at %x (size %i)\n", sf_header.active_section->start, code_size);

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
    sf_header.return_stack_size = 2*4096;
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
                if(-13 == rc) {
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
