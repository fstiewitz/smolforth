#include<config.h>
#include "../asmgen_x86_64.h"

SFWRAPFUN(EXIT)

udcell EXIT_impl_c(char* st, char* rst) {
    asmgen_RET(&sf_header.active_section->here);
    RETURN(st, rst);
}
