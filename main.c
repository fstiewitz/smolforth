/*
* smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
*/
#include "library.h"

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

char line[1024];

__attribute__((unused)) udcell dot(char *st, const char *rst) {
    cell v = pop(&st);
    printf("%li ", v);
    RETURN(st, rst);
}

__attribute__((unused)) udcell udot(char *st, const char *rst) {
    ucell v = upop(&st);
    printf("%lu ", v);
    RETURN(st, rst);
}

__attribute__((unused)) udcell CR(const char *st, const char *rst) {
    printf("\n");
    RETURN(st, rst);
}

__attribute__((unused)) udcell type(char *st, char *rst) {
    cell l = pop(&st);
    char* addr = (char *) pop(&st);
    fwrite(addr, 1, l, stdout);
    RETURN(st, rst);
}

__attribute__((unused)) udcell emit(char *st, char *rst) {
    cell l = pop(&st);
    fputc((char)l, stdout);
    RETURN(st, rst);
}

__attribute__((unused)) udcell accept(char *st, char *rst) {
    cell n = pop(&st);
    char* addr = (char *) upop(&st);
    cell l = 0;
    while(n) {
        int c = fgetc(stdin);
        if(c == -1) {
            perror("fgetc");
            break;
        }
        if(c == '\n') break;
        addr[l++] = c;
        --n;
    }
    push(l, &st);
    RETURN(st, rst);
}

char* sts;
char* rsts;

udcell quit(char *st, char *rst) {
    sys.quit_ret = 1;
    if (sys.blk == 0) {
        if (sys.source_id >= 0) {
            int i = 0;
            while (1) {
                char c;
                int r = read((int) sys.source_id, &c, 1);
                if (r != 1) {
                    if (i) break;
                    if (errno) perror("read");
                    sys.quit_ret = 0;
                    RETURN(st, rst);
                }
                if (c == 0 && i) break;
                if (c == 0) {
                    sys.quit_ret = 0;
                    RETURN(st, rst);
                }
                if (c == '\n') break;
                line[i++] = c;
            }

            line[i] = 0;
            sys.line_size = i;
            sys.line_ptr = line;
        }
    } else {
        sys.line_ptr = "sys:exit";
        sys.line_size = strlen("sys:exit");
    }
    SFCALL(st, rst, source)
    SFCALL(st, rst, evaluate)
    sts = st;
    rsts = rst;
    RETURN(st, rst);
}

char *cdata;
unsigned cdata_len;

char *stdata;
unsigned stdata_len;

char *rstdata;
unsigned rstdata_len;

#include <stdlib.h>

#include <assert.h>
#include <fcntl.h>
#include <sys/mman.h>

__attribute__((unused)) __attribute__((destructor)) void free_all() {
    munmap(cdata, cdata_len);
    munmap(stdata, stdata_len);
    munmap(rstdata, rstdata_len);
}

udcell sdad(char* st, char* rst) {
    int fd = open("abc.bin", O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if(fd == -1) {
        perror("open");
        exit(1);
    }
    ssize_t r = write(fd, cdata, sys.here - cdata);
    assert(r == sys.here - cdata);
    close(fd);
    fprintf(stderr, "wrote %u bytes of data\n", sys.here - cdata);
    RETURN(st, rst);
}

int main(int argc, char **argv) {
    sys.state = 0;
    sys.base = 10;

    cdata_len = 5 * 4096;
    cdata = mmap(0, cdata_len, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (cdata == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }
    sys.cdata = cdata;
    sys.cdata_end = cdata + cdata_len;

    stdata_len = 1024;
    stdata = mmap(0, stdata_len, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (stdata == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }
    sys.stack_start = stdata;
    sys.stack_end = stdata + stdata_len;

    rstdata_len = 1024;
    rstdata = mmap(0, rstdata_len, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (rstdata == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }
    sys.rstack_start = rstdata;
    sys.rstack_end = rstdata + rstdata_len;

    sys.current = &core_current;
    sys.here = cdata;

    sts = sys.stack_start;
    rsts = sys.rstack_start;

    for (int i = 1; i < argc; ++i) {
        int fd = open(argv[i], O_RDONLY);
        if (fd == -1) {
            perror("open");
            exit(1);
        }
        sys.blk = 0;
        sys.source_id = fd;
        sys.quit_ret = 1;

        if (setjmp(exit_jmp) == 0) {
            while (sys.quit_ret == 1) {
                c_to_sf(sts, rsts, quit);
            }
        }
        if(sys.quit_ret == 2 || sys.quit_ret == 3) {
            exit(1);
        }
    }
    return 0;
}