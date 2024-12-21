#include<config.h>

SFWRAPFUN(SM_slash_REM)

udcell SM_slash_REM_impl_c(char* st, char* rst) {
    dcell n = pop(&st);
    dcell d = dpop(&st);
    cell q = (cell) (d / n);
    cell r = (cell) (d % n);
    push(r, &st);
    push(q, &st);
    RETURN(st, rst);
}
