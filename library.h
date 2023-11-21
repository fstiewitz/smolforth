/*
* smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
*/
#ifndef SMOLFORTH_LIBRARY_H
#define SMOLFORTH_LIBRARY_H

#include <setjmp.h>
#include <stdint.h>

#ifndef __WORDSIZE
#define __WORDSIZE __riscv_xlen
#endif

#define PO_SIZE (2 * __WORDSIZE + 1)// pictured output buffer size
#define TP_SIZE 64                  // temp. buffer for WORD
#define CS_SIZE 16                  // size of control flow stack

#if __WORDSIZE == 64
typedef int64_t cell;
typedef uint64_t ucell;
typedef __int128 dcell;
typedef unsigned __int128 udcell;
#define asmgen_SX asmgen_SD
#define asmgen_LX asmgen_LD
#elif __WORDSIZE == 32
typedef int32_t cell;
typedef uint32_t ucell;
typedef int64_t dcell;
typedef uint64_t udcell;
#define asmgen_SX asmgen_SW
#define asmgen_LX asmgen_LW
#else
#error "64-bit or 32-bit required"
#endif

udcell sf_to_c(char *st, char *rst, udcell (*f)(char *st, char *rst));
udcell c_to_sf(char *st, char *rst, udcell (*f)(char *st, char *rst));

struct control_flow_t {
    void (*conditional)(signed, signed, uint32_t, char **);
    signed reg0;
    signed reg1;
    char *addr;
};

struct sys_t {
    char *cdata;
    char *cdata_end;
    char *stack_start;
    char *stack_end;
    char *rstack_start;
    char *rstack_end;
    char *here;
    cell state;
    char pictured_output[PO_SIZE];
    unsigned pictured_output_count;
    char token_pad[TP_SIZE];
    cell base;
    char *line_ptr;
    cell line_size;
    cell parse_area_offset;
    struct control_flow_t cs[CS_SIZE];
    cell cs_count;

    char *current;
    char *next_word;

    cell source_id;
    cell blk;
    cell quit_ret;
};

/*
 * OFF
 * LINK
 * FLAGS
 */
#define WORD_FLAGS(W) ((cell *) (((char *) (W)) + 2 * sizeof(cell)))
#define WORD_IMMEDIATE 1
#define WORD_DID 2
#define WORD_ADDR 4
#define WORD_CONSTANT 8

#define WORD_NAME(W) (((char *) (W)) - *(((cell *) (W))))
#define WORD_LINK(W) ((char **) (((char *) W) + sizeof(cell)))
#define WORD_DID_ADDR(W) ((udcell(*)(char *, char *)) * (cell *) (((char *) (W)) + 3 * sizeof(cell)))
#define WORD_DID_ADDR_ADDR(W) ((cell *) (((char *) (W)) + 3 * sizeof(cell)))
#define WORD_BODY(W) (               \
        (udcell(*)(char *, char *))( \
                ((char *) (W)) + 3 * sizeof(cell) + (*WORD_FLAGS(W) & WORD_DID ? sizeof(void *) : 0)))

extern struct sys_t sys;
extern jmp_buf exit_jmp;
extern char *st_end;
extern char *rst_end;
extern char core_current;

void sys_exit(char *st, char *rst);
udcell dbg_rstack(char *st, char *rst);
udcell dbg_stack(char *st, char *rst);
udcell type(char *st, char *rst);

cell pop(char **st);
void push(cell v, char **st);
ucell upop(char **st);
void upush(ucell v, char **st);
dcell dpop(char **st);
void dpush(dcell v, char **st);
udcell udpop(char **st);
void udpush(udcell v, char **st);

char *new_word();
char *next_word();
char *this_word();
void forward_current();

__attribute__((unused)) __attribute__((unused)) udcell dot(char *st, const char *rst);
__attribute__((unused)) __attribute__((unused)) udcell CR(const char *st, const char *rst);
udcell find(char *st, char *rst);
udcell evaluate(char *st, char *rst);
udcell source(char *st, char *rst);
udcell quit(char *st, char *rst);
udcell word(char *st, char *rst);
udcell bl(char *st, char *rst);

void c_push(cell v);
int c_call(ucell v);

union ret {
    udcell r;
    struct {
        ucell a0;
        ucell a1;
    };
};
#define RETURN(st, rst)  \
    union ret _r;        \
    _r.a0 = (ucell) st;  \
    _r.a1 = (ucell) rst; \
    return _r.r

#define SFCALL(st, rst, call)          \
    {                                  \
        union ret _r;                  \
        _r.r = sf_to_c(st, rst, call); \
        st = (char *) _r.a0;           \
        rst = (char *) _r.a1;          \
    }

#endif//SMOLFORTH_LIBRARY_H
