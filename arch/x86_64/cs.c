#include<config.h>

#include<string.h>
#include<limits.h>

SFWRAPFUN(SYS_LOOP)
SFWRAPFUN(SYS_plus_LOOP)
SFWRAPFUN(SYS_LEAVE)

udcell SYS_LOOP_impl_c(char* st, char* rst) {
    ucell a = bupop(&rst);
    cell final = bpop(&rst);
    cell initial = bpop(&rst);
    initial += 1;
    if (initial == final) {
        push(-1, &st);
    } else {
        push(0, &st);
        bpush(initial, &rst);
        bpush(final, &rst);
    }
    bupush(a, &rst);
    RETURN(st, rst);
}

udcell SYS_plus_LOOP_impl_c(char* st, char* rst) {
    ucell a = bupop(&rst);
    cell increment = pop(&st);
    cell final = bpop(&rst);
    cell initial = bpop(&rst);
    cell old = initial;
    initial += increment;
    old -= final;
    if (((old ^ (old + increment)) & (old ^ increment)) < 0) {
        push(-1, &st);
    } else {
        push(0, &st);
        bpush(initial, &rst);
        bpush(final, &rst);
    }
    bupush(a, &rst);
    RETURN(st, rst);
}

udcell SYS_LEAVE_impl_c(char *st, char *rst) {
    ucell a = bupop(&rst);
    rst += 2 * sizeof(cell);
    bpush(a, &rst);
    RETURN(st, rst);
}

udcell cs_leave_impl(char *st, char *rst) {
    cell *s = (void*)st;
    while (s[-4] != 2 && s[-4] != 3) {
        s -= 4;
    }
    ucell save[4];
    memcpy(save, st - 4 * sizeof(cell), 4 * sizeof(cell));
    memmove(s + 4, s, (char*)st - (char*)s);
    memcpy(s, save, 4 * sizeof(cell));
    RETURN(st, rst);
}

