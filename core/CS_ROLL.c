#include<config.h>
#include<string.h>

SFWRAPFUN(CS_ROLL)

udcell CS_ROLL_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    cell d = pop(&st);
    ucell top[4];
    memcpy(top, st - (d + 1) * 4 * sizeof(ucell), 4 * sizeof(ucell));
    memmove(st - (d + 1) * 4 * sizeof(ucell), st - d * 4 * sizeof(ucell), d * 4 * sizeof(ucell));
    memcpy(st - 4 * sizeof(ucell), top, 4 * sizeof(ucell));
    RETURN(st, rst);
}


