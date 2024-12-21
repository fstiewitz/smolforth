#include <config.h>
#include <float/float.h>

#include <alloca.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

fcell f10exp(fcell v, int *exp) {
    if(v == 0) {
        *exp = 0;
    } else {
        int i = floor(log10(fabs(v)));
        if(v < 0) i = -i;
        i += 1;
        *exp = i;
    }
    while((v < 0.1 || v >= 1.0)) {
        fcell t = v;
        if(*exp > 0) {
            v = v / 10.0;
        } else {
            v = v * 10.0;
        }
        if(t == v) break;
    }
    return v;
}

SFWRAPFUN(REPRESENT)

udcell REPRESENT_impl_c(char* st, char* rst) {
    ucell l = upop(&st);
    char* addr = (char*)upop(&st);
    fcell v = fpop();
    int exp;
    fcell sig = f10exp(fabs(v), &exp);
    push(exp, &st);
    if(isnan(v) || isinf(v)) {
        int z = snprintf(addr, l, "%F", v);
        memset(addr + z, ' ', l - z);
        push(0, &st);
        push(0, &st);
    } else if(l == 0) {
        push(0, &st);
        push(0, &st);
    } else {
        ucell sigi = round(fabs(sig) * pow(10, l));
        ucell i = l;
        while(i) {
            --i;
            cell d = sigi % 10;
            sigi /= 10;
            addr[i] = '0' + d;
        }
        push((v < 0 ? -1 : 0), &st);
        push(-1, &st);
    }
    RETURN(st, rst);
}
