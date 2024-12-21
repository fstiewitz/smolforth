#include <config.h>
#include <float/float.h>

#include <alloca.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

SFWRAPFUN(D_to_F)

udcell D_to_F_impl_c(char* st, char* rst) {
    fpush(dpop(&st));
    RETURN(st, rst);
}
