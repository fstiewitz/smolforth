#include <config.h>
#include <float/float.h>

#include <alloca.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

SFWRAPFUN(F_to_D)

udcell F_to_D_impl_c(char* st, char* rst) {
    fcell x = fpop();
    dpush((dcell)x, &st);
    RETURN(st, rst);
}
