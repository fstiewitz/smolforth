#include<config.h>

SFWRAPFUN(UM_slash_MOD)

udcell UM_slash_MOD_impl_c(char* st, char* rst) {
    udcell n = upop(&st);
    udcell d = udpop(&st);
    ucell q = (ucell) (d / n);
    ucell r = (ucell) (d % n);
    upush(r, &st);
    upush(q, &st);
    RETURN(st, rst);
}
