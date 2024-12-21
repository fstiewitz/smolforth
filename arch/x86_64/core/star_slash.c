#include<config.h>

SFWRAPFUN(star_slash)

udcell star_slash_impl_c(char* st, char* rst) {
    cell n3 = pop(&st);
    dcell n2 = pop(&st);
    dcell n1 = pop(&st);
    n1 *= n2;
    push((cell) (n1 / n3), &st);
    RETURN(st, rst);
}
