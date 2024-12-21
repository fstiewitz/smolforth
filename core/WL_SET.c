#include<config.h>

SFWRAPFUN(WL_SET)

udcell WL_SET_impl_c(char* st, char* rst) {
    void* wl = (void*)upop(&st);
    wl_search_order[0] = wl;
    RETURN(st, rst);
}

