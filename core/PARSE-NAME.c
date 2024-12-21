#include<config.h>
#include<stdio.h>

SFWRAPFUN(PARSE_NAME)

extern cell FORTH$body$PAO;

int isspace(int);

static int isspace_null(int c) {
    return isspace(c) || (c == 0);
}

udcell PARSE_NAME_impl_c(char* st, char* rst) {
    char* lptr = sf_header.line_ptr;
    cell pao = FORTH$body$PAO;
    cell lsize = sf_header.line_size;
    lptr += pao;
    while(pao < lsize) {
        if(!isspace_null(*lptr)) break;
        ++pao;
        ++lptr;
    }
    char* start = lptr;
    int i = 0;
    while(pao < lsize) {
        if(isspace_null(*lptr)) break;
        ++pao;
        ++lptr;
        ++i;
    }
    FORTH$body$PAO = pao + 1;
    upush((ucell)start, &st);
    upush(i, &st);
    RETURN(st, rst);
}

