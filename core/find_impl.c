#include<config.h>
#include <string.h>
#include <stdio.h>

static int name_eq(char* a, int al, char* b, int bl) {
    if(al != bl) return 0;
    if(memcmp(a, b, al) == 0) return 1;
    return 0;
}

udcell FIND_impl_c(char* st, char* rst) {
    char* c = (char*)upop(&st);
    unsigned char wlen = *c;
    c += 1;

    for(int i = 0; i<WL_SO_MAX - 1; ++i) {
        void** wl = wl_search_order[i];
        if(!wl) break;
        void* w = *wl;
        while(w) {
            char* n = (char*)w - 2;
            int l = 0;
            while(*n == 1) --n;
            while(*n) {
                ++l;
                --n;
            }
            ++n;
            /*fprintf(stderr, "testing ");
            fwrite(n, 1, l, stderr);
            fprintf(stderr, "(%i) against ", l);
            fwrite(c, 1, wlen, stderr);
            fprintf(stderr, "(%i)\r\n", wlen);*/
            if(name_eq(n, l, c, wlen)) {
                int flags = *((char*)w - 1);
                upush((ucell)w, &st);
                if(0 != (W_IMMEDIATE & *((char*)w - 1))) {
                    push(1, &st);
                } else {
                    push(-1, &st);
                }
                RETURN(st, rst);
            }
            w = *((void**)w);
        }
    }

    /* printf("not found\n"); */
    /*for(int i = 0; i < WL_SO_MAX - 1; ++i) {
        void** wl = wl_search_order[i];
        if(!wl) break;
        char* n = (char*)wl - 2 * sizeof(cell) - 2;
        int l = 0;
        while(*n == 1) --n;
        while(*n) {
            ++l;
            --n;
        }
        ++n;
        printf("WL ");
        fwrite(n, 1, l, stdout);
        printf("\n");
    }*/

    upush((ucell)(c - 1), &st);
    push(0, &st);

    RETURN(st, rst);
}

