#include <config.h>

SFWRAPFUN(NEXT_WORD)

extern void* next_word;

udcell NEXT_WORD_impl_c(char* st, char* rst) {
    upush((ucell)next_word, &st);
    RETURN(st, rst);
}
