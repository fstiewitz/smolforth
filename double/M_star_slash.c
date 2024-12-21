#include<config.h>
#include<unistd.h>
#include<byteswap.h>

#include<double/v_bignum.h.h>

SFWRAPFUN(M_star_slash)

#if DCELL_WIDTH == 128
#define bswap_cell bswap_64
udcell bswap_udcell(udcell i) {
    return ((udcell)bswap_64(i) << 64) | (udcell)bswap_64(i >> 64);
}
#else
#define bswap_cell bswap_32
#define bswap_udcell bswap_64
#endif

udcell M_star_slash_impl_c(char* st, char* rst) {
    ucell d = upop(&st);
    cell n = pop(&st);
    dcell u = dpop(&st);
    dcell q;
    ucell t[3];

    int nn = 0;
    int un = 0;

    if(n < 0) {
        n = -n;
        nn = -1;
    }

    if(u < 0) {
        u = -u;
        un = -1;
    }

    d = bswap_cell(d);
    n = bswap_cell(n);
    u = bswap_udcell(u);

    VBigDig VBIGNUM(dv, CELL_WIDTH),
    VBIGNUM(nv, CELL_WIDTH),
    VBIGNUM(uv, DCELL_WIDTH),
    VBIGNUM(tv, 3*CELL_WIDTH);

    v_bignum_raw_import(dv, &d);
    v_bignum_raw_import(nv, &n);
    v_bignum_raw_import(uv, &u);
    v_bignum_set_bignum(tv, uv);
    v_bignum_mul(tv, nv);
    v_bignum_div(tv, dv, 0);
    v_bignum_set_bignum(uv, tv);
    v_bignum_raw_export(uv, &q);

    q = (bswap_udcell(q) << 1) >> 1;

    if(un != nn) {
        q = -q;
    }

    if(un != nn && q == 0 && u != 0 && n != 0) {
        q = (udcell)1 << (DCELL_WIDTH - 1);
    }

    dpush(q, &st);

    RETURN(st, rst);
}
