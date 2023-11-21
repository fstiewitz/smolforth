/*
* smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
*/
#include "library.h"
#include "asmgen_riscv.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct sys_t sys;
jmp_buf exit_jmp;
char *st_end;
char *rst_end;

#include "config.h"

void check_bounds(void *ptr, const char *str, char *st, char *rst);

cell pop(char **st) {
    *st -= sizeof(cell);
    return *(cell *) *st;
}

void push(cell v, char **st) {
    *(cell *) *st = v;
    *st += sizeof(cell);
}

ucell upop(char **st) {
    *st -= sizeof(ucell);
    return *(ucell *) *st;
}

void upush(ucell v, char **st) {
    *(ucell *) *st = v;
    *st += sizeof(ucell);
}

dcell dpop(char **st) {
    ucell nh = upop(st);
    ucell nl = upop(st);
    return (dcell) (((udcell) nh << (8 * sizeof(cell))) | (udcell) nl);
}

void dpush(dcell v, char **st) {
    push((cell) (v & (((dcell) 1 << (8 * sizeof(cell))) - 1)), st);
    push((cell) (v >> (8 * sizeof(cell))), st);
}

udcell udpop(char **st) {
    ucell nh = upop(st);
    ucell nl = upop(st);
    return (((udcell) nh << (8 * sizeof(cell))) | (udcell) nl);
}

void udpush(udcell v, char **st) {
    upush((ucell) (v & (((udcell) 1 << (8 * sizeof(cell))) - 1)), st);
    upush((ucell) (v >> (8 * sizeof(cell))), st);
}

char *new_word(char *w) {
    char l = *w;
    ++w;
    memcpy(sys.here, w, l);
    *(sys.here + l) = 0;
    l += 1;
    sys.here += l;
    if (((ucell) sys.here) % 4) {
        l += 4 - (((ucell) sys.here) % 4);
        sys.here += 4 - (((ucell) sys.here) % 4);
    }
    sys.next_word = sys.here;
    *(cell *) sys.next_word = l;
    sys.here += 3 * sizeof(cell);
    return sys.next_word;
}

char *next_word() {
    return sys.next_word;
}

char *this_word() {
    return sys.current;
}

void forward_current() {
    sys.current = sys.next_word;
}

#ifdef SF_WORD_WORD
udcell word(char *st, char *rst) {
    char delim = pop(&st);
    int b = 1;
    int j = 1;
    cell i;
    for (i = sys.parse_area_offset; i < sys.line_size; ++i) {
        if (b && (sys.line_ptr[i] == delim || (isspace(delim) && isspace(sys.line_ptr[i])))) {
        } else if (b) {
            b = 0;
        }
        if (!b) {
            if (sys.line_ptr[i] == delim || (isspace(delim) && isspace(sys.line_ptr[i]))) {
                break;
            }
            sys.token_pad[j++] = sys.line_ptr[i];
        }
    }

    sys.token_pad[0] = j - 1;
    sys.token_pad[j] = 0;
    sys.parse_area_offset = i + 1;
    push((cell) sys.token_pad, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_SOURCE
udcell source(char *st, char *rst) {
    push((cell) sys.line_ptr, &st);
    push(sys.line_size, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_EXECUTE
udcell execute(char *st, char *rst) {
    char *word = (char *) pop(&st);
    char flags = *WORD_FLAGS(word);
    if (flags & WORD_ADDR) {
        //printf("push %p %s\n", WORD_BODY(word), WORD_NAME(word));
        push((cell) WORD_BODY(word), &st);
        if ((flags & WORD_DID) && WORD_DID_ADDR(word)) {
            //printf("call DOES> %p %s\n", WORD_DID_ADDR(word), WORD_NAME(word));
            SFCALL(st, rst, WORD_DID_ADDR(word))
        }
    } else if (flags & WORD_CONSTANT) {
        //printf("push constant %lx %s\n", *(cell*)WORD_BODY(word), WORD_NAME(word));
        push(*(cell *) WORD_BODY(word), &st);
    } else {
        //printf("call %p %s\n", WORD_BODY(word), WORD_NAME(word));
        SFCALL(st, rst, WORD_BODY(word))
    }
    RETURN(st, rst);
}
#endif

udcell compile(char *st, char *rst) {
    char *word = (char *) pop(&st);
    char flags = *WORD_FLAGS(word);
    if (flags & WORD_ADDR) {
        //printf("compile push %p %s\n", WORD_BODY(word), WORD_NAME(word));
        c_push((cell) WORD_BODY(word));
        if ((flags & WORD_DID) && WORD_DID_ADDR(word)) {
            //printf("compile call %p %s\n", WORD_DID_ADDR(word), WORD_NAME(word));
            if (c_call((cell) WORD_DID_ADDR(word))) {
                sys.quit_ret = 3;
                sys_exit(st, rst);
            }
        }
    } else if (flags & WORD_CONSTANT) {
        //printf("compile constant %lx %s\n", *(cell*)WORD_BODY(word), WORD_NAME(word));
        c_push(*(cell *) WORD_BODY(word));
    } else {
        //printf("compile call %p %s\n", WORD_BODY(word), WORD_NAME(word));
        if (c_call((cell) WORD_BODY(word))) {
            sys.quit_ret = 3;
            sys_exit(st, rst);
        }
    }
    RETURN(st, rst);
}

udcell evaluate_(char *st, char *rst) {
    char *w = (char *) pop(&st);
    char *p;
    char len = w[0];
    push((cell) w, &st);
    SFCALL(st, rst, find)
    if (!pop(&st)) {
        pop(&st);
        cell l = strtoll(w + 1, &p, sys.base);
        if (p - (w + 1) == len) {
            if (sys.state) {
                // printf("compile push %li\n", l);
                c_push(l);
            } else {
                // printf("push %li\n", l);
                push(l, &st);
            }
            RETURN(st, rst);
        }
        printf("unknown word '%s'\n", w + 1);
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    char *word = (char *) pop(&st);
    char flags = *WORD_FLAGS(word);
    push((cell) word, &st);
    if (sys.state && !(flags & WORD_IMMEDIATE)) {
        SFCALL(st, rst, compile)
    } else {
        SFCALL(st, rst, execute)
    }
    RETURN(st, rst);
}

#ifdef SF_WORD_EVALUATE
udcell evaluate(char *st, char *rst) {
    cell ls = sys.line_size;
    char *lp = sys.line_ptr;
    cell pao = sys.parse_area_offset;
    cell blk = sys.blk;
    cell source_id = sys.source_id;

    sys.line_size = pop(&st);
    sys.line_ptr = (char *) pop(&st);
    sys.parse_area_offset = 0;

    while (1) {
        SFCALL(st, rst, bl)
        SFCALL(st, rst, word)
        char *c = (char *) pop(&st);
        if (c[0]) {
            push((cell) c, &st);
            SFCALL(st, rst, evaluate_)
        } else {
            break;
        }
    }

    sys.line_size = ls;
    sys.line_ptr = lp;
    sys.parse_area_offset = pao;
    sys.blk = blk;
    sys.source_id = source_id;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_FIND
udcell find(char *st, char *rst) {
    char *pad = (char *) pop(&st);
    uint8_t l = *((uint8_t *) pad);
    ++pad;
    char buffer[256];
    strncpy(buffer, pad, l);
    buffer[l] = 0;
    char *w = sys.current;
    if (w == 0) {
        push((cell) pad - 1, &st);
        push(0, &st);
        RETURN(st, rst);
    }
    while (w) {
        char *name = WORD_NAME(w);
        if (l == strlen(name) && strcmp(name, buffer) == 0) {
            push((cell) w, &st);
            if (*WORD_FLAGS(w) & WORD_IMMEDIATE) {
                push(1, &st);
            } else {
                push(-1, &st);
            }
            RETURN(st, rst);
        }
        w = *WORD_LINK(w);
    }
    push((cell) pad - 1, &st);
    push(0, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_BL
udcell bl(char *st, char *rst) {
    push(' ', &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_EXIT
__attribute__((noreturn)) void sys_exit(char *st, char *rst) {
    st_end = st;
    rst_end = rst;
    longjmp(exit_jmp, 1);
}
#endif

void c_store(signed reg, ucell v) {
#if __WORDSIZE == 64
    if (v > 0xffffffff) {
        c_store(reg + 1, v >> 32);
        asmgen_ADDI(T0, X0, 32, &sys.here);
        asmgen_SLL(reg + 1, reg + 1, T0, &sys.here);
        c_store(reg, v & 0xffffffff);
        asmgen_SLL(reg, reg, T0, &sys.here);
        asmgen_SRL(reg, reg, T0, &sys.here);
        asmgen_OR(reg, reg, reg + 1, &sys.here);
        return;
    }
#endif
    int32_t x = (int32_t) v;
    uint32_t lower = (x << 20) >> 20;
    uint32_t upper = ((x - lower) >> 12);
    if (upper) {
        asmgen_LUI(reg, upper, &sys.here);
        asmgen_ADDI(reg, reg, lower, &sys.here);
    } else {
        asmgen_ADDI(reg, X0, lower, &sys.here);
    }
}

void c_save_ra() {
    asmgen_SX(RA, A1, 0, &sys.here);
    asmgen_ADDI(A1, A1, sizeof(cell), &sys.here);
}

void c_return() {
    asmgen_ADDI(A1, A1, -(int) sizeof(cell), &sys.here);
    asmgen_LX(RA, A1, 0, &sys.here);
    asmgen_JALR(X0, RA, 0, &sys.here);
}

void c_push(cell v) {
    c_store(A2, v);
    asmgen_SX(A2, A0, 0, &sys.here);
    asmgen_ADDI(A0, A0, sizeof(cell), &sys.here);
}

int c_call(ucell v) {
    int32_t y = (v - (ucell) sys.here);
    uint32_t lower = (y << 20) >> 20;
    uint32_t upper = ((y - lower) >> 12);
    asmgen_AUIPC(RA, upper, &sys.here);
    asmgen_JALR(RA, RA, lower, &sys.here);
    return 0;
}

#ifdef SF_WORD_LINE_COMMENT
udcell line_comment(char *st, char *rst) {
    char* ch = memchr(sys.line_ptr + sys.parse_area_offset, '\n', sys.line_size - sys.parse_area_offset);
    if(ch) {
        sys.parse_area_offset = ch - sys.line_ptr + 1;
    } else {
        sys.parse_area_offset = sys.line_size;
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_HEX
udcell hex(char *st, char *rst) {
    sys.base = 16;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_VARIABLE
udcell variable(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }

    char *w = new_word(c);
    *WORD_LINK(w) = sys.current;
    *WORD_FLAGS(w) = WORD_ADDR;

    sys.here += sizeof(cell);

    // printf("VARIABLE %s\n", c + 1);
    forward_current();

    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_COMPILE_START
udcell compile_start(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }

    char *w = new_word(c);
    *WORD_LINK(w) = sys.current;
    *WORD_FLAGS(w) = 0;

    // printf(": %p %p %s\n", sys.here, sys.cdata, c + 1);

    sys.state = 1;
    c_save_ra();

    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_COMPILE_END
udcell compile_end(char *st, char *rst) {
    forward_current();
    c_return();
    sys.state = 0;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_DEPTH
udcell depth(char *st, char *rst) {
    cell l = (cell *) st - (cell *) sys.stack_start;
    push(l, &st);
    RETURN(st, rst);
}
#endif

void cs_dbg() {
    cell cs = sys.cs_count - 1;
    printf("CS\n");
    while (cs >= 0) {
        printf("\t%li %p\n", sys.cs[cs].conditional, sys.cs[cs].addr);
        --cs;
    }
}

#ifdef SF_WORD_IF
udcell cs_if(char *st, char *rst) {
    struct control_flow_t cnt = {
            .conditional = asmgen_BEQ,
            .reg0 = A2,
            .reg1 = X0};
    asmgen_ADDI(A0, A0, -(int) sizeof(cell), &sys.here);
    asmgen_LX(A2, A0, 0, &sys.here);
    cnt.addr = sys.here;
    asmgen_BEQ(A2, X0, 0, &sys.here);
    sys.cs[sys.cs_count++] = cnt;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_THEN
udcell cs_then(char *st, char *rst) {
    struct control_flow_t *cnt = &sys.cs[--sys.cs_count];
    if (cnt->conditional) {
        cnt->conditional(cnt->reg0, cnt->reg1, sys.here - cnt->addr, &cnt->addr);
    } else {
        asmgen_JAL(X0, sys.here - cnt->addr, &cnt->addr);
    }
    RETURN(st, rst);
}
#endif

udcell cs_ahead(char *st, char *rst) {
    struct control_flow_t cnt = {
            .conditional = 0,
            .addr = sys.here};
    sys.cs[sys.cs_count++] = cnt;
    asmgen_JAL(X0, 0, &sys.here);
    RETURN(st, rst);
}

udcell cs_roll(char *st, char *rst) {
    cell r = pop(&st);
    struct control_flow_t cnt = sys.cs[sys.cs_count - r - 1];
    memmove(sys.cs + sys.cs_count - r - 1, sys.cs + sys.cs_count - r, r * sizeof(struct control_flow_t));
    sys.cs[sys.cs_count - 1] = cnt;
    RETURN(st, rst);
}

#ifdef SF_WORD_ELSE
udcell cs_else(char *st, char *rst) {
    SFCALL(st, rst, cs_ahead)
    push(1, &st);
    SFCALL(st, rst, cs_roll)
    SFCALL(st, rst, cs_then)
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_BEGIN
udcell cs_begin(char *st, char *rst) {
    struct control_flow_t cnt = {
            .conditional = 0,
            .addr = sys.here};
    sys.cs[sys.cs_count++] = cnt;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_UNTIL
udcell cs_until(char *st, char *rst) {
    struct control_flow_t *cnt = &sys.cs[--sys.cs_count];
    asmgen_ADDI(A0, A0, -(int) sizeof(cell), &sys.here);
    asmgen_LX(A2, A0, 0, &sys.here);
    asmgen_BEQ(A2, X0, cnt->addr - sys.here, &sys.here);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_WHILE
udcell cs_while(char *st, char *rst) {
    asmgen_ADDI(A0, A0, -(int) sizeof(cell), &sys.here);
    asmgen_LX(A2, A0, 0, &sys.here);
    struct control_flow_t cnt = {
            .conditional = asmgen_BEQ,
            .reg0 = A2,
            .reg1 = X0,
            .addr = sys.here};
    sys.cs[sys.cs_count++] = cnt;
    asmgen_BEQ(A2, X0, 0, &sys.here);
    push(1, &st);
    SFCALL(st, rst, cs_roll);
    RETURN(st, rst);
}
#endif

udcell cs_again(char *st, char *rst) {
    struct control_flow_t *cnt = &sys.cs[--sys.cs_count];
    asmgen_JAL(X0, cnt->addr - sys.here, &sys.here);
    RETURN(st, rst);
}

#ifdef SF_WORD_REPEAT
udcell cs_repeat(char *st, char *rst) {
    SFCALL(st, rst, cs_again);
    SFCALL(st, rst, cs_then);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_DO
udcell cs_do_(char *st, char *rst) {
    cell a1 = pop(&st);
    cell a2 = pop(&st);
    push(a1, &rst);
    push(a2, &rst);
    RETURN(st, rst);
}

udcell cs_do(char *st, char *rst) {
    if (c_call((cell) cs_do_)) {
        sys_exit(st, rst);
    }
    struct control_flow_t cnt = {
            .conditional = 0,
            .addr = (void *) 2};
    sys.cs[sys.cs_count++] = cnt;
    SFCALL(st, rst, cs_begin)
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_LOOP
udcell cs_loop_(char *st, char *rst) {
    cell final = pop(&rst);
    cell initial = pop(&rst);
    initial += 1;
    if (initial == final) {
        push(-1, &st);
    } else {
        push(0, &st);
        push(initial, &rst);
        push(final, &rst);
    }
    RETURN(st, rst);
}

udcell cs_loop(char *st, char *rst) {
    if (c_call((cell) cs_loop_)) {
        sys_exit(st, rst);
    }
    SFCALL(st, rst, cs_until)

    while (sys.cs[sys.cs_count - 1].addr != (void *) 2) {
        assert(sys.cs_count);
        SFCALL(st, rst, cs_then)
    }
    sys.cs_count -= 1;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_PLUS_LOOP
udcell cs_plus_loop_(char *st, char *rst) {
    cell increment = pop(&st);
    cell final = pop(&rst);
    cell initial = pop(&rst);
    initial += increment;
    if ((initial < final && increment < 0) || (initial > final && increment > 0)) {
        push(-1, &st);
    } else {
        push(0, &st);
        push(initial, &rst);
        push(final, &rst);
    }
    RETURN(st, rst);
}

udcell cs_plus_loop(char *st, char *rst) {
    if (c_call((cell) cs_plus_loop_)) {
        sys_exit(st, rst);
    }
    SFCALL(st, rst, cs_until)

    while (sys.cs[sys.cs_count - 1].addr != (void *) 2) {
        assert(sys.cs_count);
        SFCALL(st, rst, cs_then)
    }
    sys.cs_count -= 1;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_CREATE
udcell create(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }

    char *w = new_word(c);
    *WORD_LINK(w) = sys.current;
    *WORD_FLAGS(w) = WORD_ADDR | WORD_DID;
    *(cell *) (sys.here) = 0;
    sys.here += sizeof(cell);

    // printf("CREATE %p %s\n", sys.here, c + 1);
    forward_current();

    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_ALLOT
udcell allot(char *st, char *rst) {
    cell a = pop(&st);
    sys.here += a;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_STRING_START
udcell s_start(char *st, char *rst) {
    char *s = sys.here;
    asmgen_JAL(X0, 0, &sys.here);
    char *ss = sys.here;
    cell l = 0;
    while (sys.parse_area_offset < sys.line_size) {
        char i = sys.line_ptr[sys.parse_area_offset];
        if (i == '"') {
            sys.parse_area_offset += 1;
            break;
        }
        *(sys.here++) = i;
        sys.parse_area_offset += 1;
        ++l;
    }
    if ((cell) sys.here % 4) {
        sys.here += 4 - ((cell) sys.here % 4);
    }
    asmgen_JAL(X0, sys.here - s, &s);
    c_push((cell) ss);
    c_push(l);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_DOT_STRING
udcell dot_string(char *st, char *rst) {
    SFCALL(st, rst, s_start)
    c_call((ucell) type);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_LEAVE
udcell leave_(char *st, char *rst) {
    rst -= 2 * sizeof(cell);
    RETURN(st, rst);
}

udcell leave(char *st, char *rst) {
    if (c_call((cell) leave_)) {
        sys_exit(st, rst);
    }
    SFCALL(st, rst, cs_ahead)

    int cs = sys.cs_count;
    while (sys.cs[cs - 1].addr != (void *) 2) {
        assert(cs - 1 >= 0);
        --cs;
    }
    struct control_flow_t cnt = sys.cs[sys.cs_count - 1];
    memmove(sys.cs + cs + 1, sys.cs + cs, (sys.cs_count - 1 - cs) * sizeof(struct control_flow_t));
    sys.cs[cs] = cnt;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_TO_IN
udcell to_in(char *st, char *rst) {
    upush((ucell) &sys.parse_area_offset, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_DBG_RSTACK
udcell dbg_rstack(char *st, char *rst) {
    cell *r = (cell *) rst;
    --r;
    while (r >= (cell *) sys.rstack_start) {
        printf("\t- %lx\n", *(r--));
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_DBG_RSTACK
udcell dbg_stack(char *st, char *rst) {
    cell *r = (cell *) st;
    --r;
    printf("STACK\n");
    while (r >= (cell *) sys.stack_start) {
        printf("\t- %lx\n", *(r--));
    }
    printf("END STACK\n");
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_COMMENT
udcell comment_start(char *st, char *rst) {
    while (sys.parse_area_offset < sys.line_size) {
        if (sys.line_ptr[sys.parse_area_offset++] == ')') {
            break;
        }
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_FM_MOD
udcell fm_mod(char *st, char *rst) {
    dcell n = pop(&st);
    dcell d = dpop(&st);
    cell q = (cell) (d / n);
    cell r = (cell) (d % n);
    if (r != 0 && ((d < 0) ^ (n < 0))) {
        --q;
        r += (cell) n;
    }
    push(r, &st);
    push(q, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_SM_REM
udcell sm_rem(char *st, char *rst) {
    dcell n = pop(&st);
    dcell d = dpop(&st);
    cell q = (cell) (d / n);
    cell r = (cell) (d % n);
    push(r, &st);
    push(q, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_UM_MOD
udcell um_mod(char *st, char *rst) {
    udcell n = upop(&st);
    udcell d = udpop(&st);
    ucell q = (ucell) (d / n);
    ucell r = (ucell) (d % n);
    upush(r, &st);
    upush(q, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_INTERP_START
udcell interp_start(char *st, char *rst) {
    sys.state = 0;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_INTERP_END
udcell interp_end(char *st, char *rst) {
    sys.state = 1;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_MUL_DIV_MOD
udcell muldivmod(char *st, char *rst) {
    cell n3 = pop(&st);
    dcell n2 = pop(&st);
    dcell n1 = pop(&st);
    n1 *= n2;
    push((cell) (n1 % n3), &st);
    push((cell) (n1 / n3), &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_MUL_DIV
udcell muldiv(char *st, char *rst) {
    cell n3 = pop(&st);
    dcell n2 = pop(&st);
    dcell n1 = pop(&st);
    n1 *= n2;
    push((cell) (n1 / n3), &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_LITERAL
udcell literal(char *st, char *rst) {
    cell c = pop(&st);
    c_push(c);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_POSTPONE
udcell postpone(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    push((cell) c, &st);
    SFCALL(st, rst, find)
    if (!pop(&st)) {
        printf("unknown word %s\n", c + 1);
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    char *word = (char *) pop(&st);
    cell flags = *WORD_FLAGS(word);

    if (flags & WORD_IMMEDIATE) {
        c_push((cell) word);
        c_call((ucell) execute);
    } else {
        c_push((cell) word);
        c_call((ucell) compile);
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_C_COMMA
udcell c_comma(char *st, char *rst) {
    ucell v = upop(&st);
    *(sys.here++) = (unsigned char) v;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_COMMA
udcell comma(char *st, char *rst) {
    ucell v = upop(&st);
    *(ucell *) (sys.here) = v;
    sys.here += sizeof(ucell);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_ALIGN
udcell align(char *st, char *rst) {
    if ((ucell) sys.here % sizeof(cell)) {
        sys.here += sizeof(cell) - ((ucell) sys.here % sizeof(cell));
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_HERE
udcell here(char *st, char *rst) {
    upush((ucell) sys.here, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_CONSTANT
udcell constant(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }

    char *w = new_word(c);
    *WORD_LINK(w) = sys.current;
    *WORD_FLAGS(w) = WORD_CONSTANT;
    assert(st > sys.stack_start);
    ucell x = upop(&st);
    *(ucell *) sys.here = x;
    sys.here += sizeof(cell);

    // printf("CONSTANT %s = %x\n", c + 1, x);
    forward_current();

    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_CHAR
udcell char_literal(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    push(c[1], &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_CHAR_COMP
udcell char_literal_comp(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    c_push(c[1]);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_STATE
udcell state(char *st, char *rst) {
    push((cell) &sys.state, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_COUNT
udcell count(char *st, char *rst) {
    char *addr = (char *) pop(&st);
    push((cell) (addr + 1), &st);
    push(*addr, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_IMMEDIATE
udcell immediate(char *st, char *rst) {
    *WORD_FLAGS(this_word()) |= WORD_IMMEDIATE;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_TICK
udcell tick(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    push((cell) c, &st);
    SFCALL(st, rst, find)
    if (!pop(&st)) {
        printf("unknown word %s\n", c + 1);
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_TICK_COMP
udcell bracket_tick(char *st, char *rst) {
    SFCALL(st, rst, bl)
    SFCALL(st, rst, word)
    char *c = (char *) pop(&st);
    if (!c[0]) {
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    push((cell) c, &st);
    SFCALL(st, rst, find)
    if (!pop(&st)) {
        printf("unknown word %s\n", c + 1);
        sys.quit_ret = 2;
        sys_exit(st, rst);
    }
    cell v = pop(&st);
    c_push(v);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_RECURSE
udcell recurse(char *st, char *rst) {
    push((cell) next_word(), &st);
    SFCALL(st, rst, compile);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_TO_BODY
udcell body(char *st, char *rst) {
    char *w = (char *) pop(&st);
    upush((ucell) WORD_BODY(w), &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_TO_DOES
udcell does_do_(char *st, char *rst, uint32_t *ra) {
    char *w = this_word();
    ++ra;
    while (*ra != 0x00008067) {
        ++ra;
    }
    ++ra;
    *WORD_DID_ADDR_ADDR(w) = (cell) ra;
    //printf("DOES> to %p\n", ra);
    RETURN(st, rst);
}

__attribute__((naked))
udcell
does_do(char *st, char *rst) {
    __asm__ volatile(
            "mv a2, ra\n"
            "tail does_do_\n");
}

udcell does(char *st, char *rst) {
    c_call((cell) does_do);
    c_return();
    c_save_ra();
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_HOLD
udcell hold(char *st, char *rst) {
    char c = upop(&st);
    sys.pictured_output[sys.pictured_output_count--] = c;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_PO_START
udcell po_start(char *st, char *rst) {
    sys.pictured_output_count = PO_SIZE - 1;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_PO_END
udcell po_end(char *st, char *rst) {
    udpop(&st);
    push((cell) (sys.pictured_output + sys.pictured_output_count + 1), &st);
    push(PO_SIZE - sys.pictured_output_count - 1, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_SIGN
udcell sign(char *st, char *rst) {
    cell v = pop(&st);
    if (v < 0) {
        push('-', &st);
        SFCALL(st, rst, hold)
    }
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_PO_NUMBER
udcell number_sign(char *st, char *rst) {
    udcell v = udpop(&st);
    udcell q = v / sys.base;
    ucell r = (ucell) (v % sys.base);
    if (r < 10) {
        push('0' + r, &st);
    } else if (r < 37) {
        push('A' + (r - 10), &st);
    } else {
        push('#', &st);
    }
    SFCALL(st, rst, hold)
    udpush(q, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_PO_NUMBER_S
udcell number_sign_s(char *st, char *rst) {
    udcell v;
    while (1) {
        SFCALL(st, rst, number_sign)
        v = udpop(&st);
        if (v == 0) break;
        udpush(v, &st);
    }
    udpush(v, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_DECIMAL
udcell decimal(char *st, char *rst) {
    sys.base = 10;
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_BASE
udcell base(char *st, char *rst) {
    push((cell) &sys.base, &st);
    RETURN(st, rst);
}
#endif

#ifdef SF_WORD_TO_NUMBER
udcell to_digit(char *st, char *rst) {
    char c = pop(&st);
    if (c >= '0' && c <= '9') push(c - '0', &st);
    else if (c >= 'a' && c <= 'z')
        push(c - 'a' + 10, &st);
    else if (c >= 'A' && c <= 'Z')
        push(c - 'A' + 10, &st);
    else
        push(-1, &st);
    RETURN(st, rst);
}

udcell to_number(char *st, char *rst) {
    ucell u = upop(&st);
    char *addr = (char *) upop(&st);
    udcell ud = udpop(&st);

    ucell i;
    for (i = 0; i < u; ++i) {
        push(*addr, &st);
        SFCALL(st, rst, to_digit)
        cell d = pop(&st);
        if (d == -1 || d >= sys.base) break;
        ud = ud * sys.base + d;
        ++addr;
    }

    udpush(ud, &st);
    upush((ucell) addr, &st);
    upush(u - i, &st);

    RETURN(st, rst);
}
#endif

void check_bounds(void *ptr, const char *str, char *st, char *rst) {
    if (!((ptr >= (void *) sys.cdata && ptr < (void *) sys.cdata_end)
          || (ptr >= (void *) sys.stack_start && ptr < (void *) sys.stack_end)
          || (ptr >= (void *) sys.rstack_start && ptr < (void *) sys.rstack_end)
          || (ptr >= (void *) sys.line_ptr && ptr < (void *) (sys.line_ptr + sys.line_size))
          || (ptr >= (void *) &sys && ptr < (void *) (&sys + 1))
          )) {
        printf("%p %s outside of bounds\n", ptr, str);
        printf("REGIONS:\n");
        printf("\t%p - %p\n", sys.cdata, sys.cdata_end);
        printf("\t%p - %p\n", sys.stack_start, sys.stack_end);
        printf("\t%p - %p\n", sys.rstack_start, sys.rstack_end);
        printf("\t%p - %p\n", sys.line_ptr, sys.line_ptr + sys.line_size);
        printf("\t%p - %p\n", &sys, &sys + 1);
        sys_exit(st, rst);
    }
}

#ifdef SF_WORD_FETCH

udcell fetch(char *st, char *rst) {
    ucell *c = (ucell *) upop(&st);
    check_bounds(c, "@", st, rst);
    upush(*c, &st);
    RETURN(st, rst);
}

#endif

#ifdef SF_WORD_STORE

udcell store(char *st, char *rst) {
    ucell *c = (ucell *) upop(&st);
    ucell v = upop(&st);
    check_bounds(c, "!", st, rst);
    *c = v;
    RETURN(st, rst);
}

#endif

#ifdef SF_WORD_PLUS_STORE

udcell plus_store(char *st, char *rst) {
    cell *c = (cell *) upop(&st);
    cell inc = pop(&st);
    check_bounds(c, "+!", st, rst);
    *c += inc;
    RETURN(st, rst);
}

#endif

#ifdef SF_WORD_TWO_FETCH

udcell fetch2(char *st, char *rst) {
    ucell *c = (ucell *) upop(&st);
    check_bounds(c, "2@", st, rst);
    upush(c[1], &st);
    upush(c[0], &st);
    RETURN(st, rst);
}

#endif

#ifdef SF_WORD_TWO_STORE

udcell store2(char *st, char *rst) {
    ucell *c = (ucell *) upop(&st);
    ucell b = upop(&st);
    ucell a = upop(&st);
    check_bounds(c, "2!", st, rst);
    c[0] = b;
    c[1] = a;
    RETURN(st, rst);
}

#endif
