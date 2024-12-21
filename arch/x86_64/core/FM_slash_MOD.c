#include<config.h>

SFWRAPFUN(FM_slash_MOD)

udcell FM_slash_MOD_impl_c(char* st, char* rst) {
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
