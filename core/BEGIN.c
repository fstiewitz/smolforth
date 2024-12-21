#include<config.h>

SFWRAPFUN(BEGIN)

udcell BEGIN_impl_c(char* st, char* rst) {
    ++sf_header.csri;
    upush((ucell)sf_header.active_section->here, &st);
    upush(0, &st);
    upush(0, &st);
    upush(0, &st);
    RETURN(st, rst);
}
