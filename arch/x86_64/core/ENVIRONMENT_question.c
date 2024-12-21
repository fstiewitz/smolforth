#include<config.h>

#include<string.h>

SFWRAPFUN(ENVIRONMENT_question)

void max_d(char** st, char** rst) {
    dcell v = ((dcell)1 << (DCELL_WIDTH - 1)) - 1;
    dpush(v, st);
}

void max_ud(char** st, char** rst) {
    udcell v = -1;
    udpush(v, st);
}

#ifndef SF_HAS_EMBEDDED
void stack_cells(char** st, char** rst) {
    push(sf_header.stack_size, st);
}

void return_stack_cells(char** st, char** rst) {
    push(sf_header.return_stack_size, st);
}
#endif

#include "../environment_functions.h"

#ifdef SF_HAS_O2
#define OPTIM_LEVEL 2
#else
#ifdef SF_HAS_O1
#define OPTIM_LEVEL 1
#else
#define OPTIM_LEVEL 0
#endif
#endif

struct query_t {
    const char* q;
    int f;
    union {
        void (*fn)(char** st, char** rst);
        cell i;
    };
} queries[] = {
{"/COUNTED-STRING", 1, {.i= 256}},
{"/HOLD", 1, {.i= 256-1}},
{"/PAD", 1, {.i= 84}},
{"ADDRESS-UNIT-BITS", 1, {.i= 8*sizeof(void*)}},
{"CORE", 1, {.i = -1}},
{"CORE-EXT", 1, {.i = -1}},
{"X86-64", 1, {.i = -1}},
{"EXCEPTION", 1, {.i = -1}},
{"EXCEPTION-EXT", 1, {.i = -1}},
{"FLOORED", 1, {.i = 0}},
{"MAX-CHAR", 1, {.i = 255}},
{"MAX-D", 0, {.fn = max_d}},
{"MAX-UD", 0, {.fn = max_ud}},
{"MAX-N", 1, {.i = CELL_MAX}},
{"MAX-U", 1, {.i = UCELL_MAX}},
#ifndef SF_HAS_EMBEDDED
{"STACK-CELLS", 0, {.fn = stack_cells}},
{"RETURN-STACK-CELLS", 0, {.fn = return_stack_cells}},
{"WORDLISTS", 1, {.i = WL_SO_MAX}},
#ifdef SF_WANTS_EMBEDDED
{"EMBEDDED", 1, {.i = -1}},
#endif
#else
{"EMBEDDED", 1, {.i = -1}},
#endif
#include "../environment_queries.h"
{"OPTIMIZATION-LEVEL", 1, {.i = OPTIM_LEVEL}},
{0, 0},
};

udcell ENVIRONMENT_question_impl_c(char* st, char* rst) {
    int l = pop(&st);
    char* s = (void*)upop(&st);
    struct query_t *q = queries;
    while(q->q) {
        if(strlen(q->q) == l && memcmp(q->q, s, l) == 0) {
            if(q->f) {
                push(q->i, &st);
            } else {
                q->fn(&st, &rst);
            }
            push(-1, &st);
            RETURN(st, rst);
        }
        ++q;
    }
    push(0, &st);
    RETURN(st, rst);
}
