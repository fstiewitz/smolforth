#include<config.h>
#include<string.h>

SFWRAPFUN(CS_PICK)

udcell CS_PICK_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    cell d = pop(&st);
    memcpy(st, st - (d + 1) * 4 * sizeof(ucell), 4 * sizeof(ucell));
    st += 4 * sizeof(ucell);
    RETURN(st, rst);
}
