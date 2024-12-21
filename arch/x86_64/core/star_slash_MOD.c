#include<config.h>

SFWRAPFUN(star_slash_MOD)

udcell star_slash_MOD_impl_c(char* st, char* rst) {
    cell n3 = pop(&st);
    dcell n2 = pop(&st);
    dcell n1 = pop(&st);
    n1 *= n2;
    push((cell) (n1 % n3), &st);
    push((cell) (n1 / n3), &st);
    RETURN(st, rst);
}
