#include<config.h>
#include<stdio.h>

SFWRAPFUN(WORD)

char tokenpad[256];

extern cell FORTH$body$PAO;

int isspace(int c) {
    switch(c) {
        case ' ':
        case '\f':
        case '\n':
        case '\r':
        case '\t':
        case '\v':
            return 1;
        default:
            return 0;
    }
}


static int isspace_null(int c) {
    return isspace(c) || (c == 0);
}

udcell WORD_impl_c(char* st, char* rst) {
    char bl = pop(&st);
    char* lptr = sf_header.line_ptr;
    cell pao = FORTH$body$PAO;
    cell lsize = sf_header.line_size;
    lptr += pao;
    while(pao < lsize) {
        if(!isspace_null(*lptr)) break;
        ++pao;
        ++lptr;
    }
    int i = 1;
    while(pao < lsize) {
        if(isspace(bl)) {
            if(isspace_null(*lptr)) break;
        } else {
            if(bl == *lptr) break;
        }
        tokenpad[i++] = *lptr;
        ++pao;
        ++lptr;
    }
    FORTH$body$PAO = pao + 1;
    tokenpad[0] = i - 1;
    upush((ucell)tokenpad, &st);
    /*fprintf(stderr, "%i %i %i - ", i - 1, pao, lsize);
    fwrite(tokenpad + 1, 1, tokenpad[0], stderr);
    fputc('\r', stderr);
    fputc('\n', stderr);*/
    RETURN(st, rst);
}

