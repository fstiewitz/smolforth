#include <config.h>

#include <stdlib.h>
#include <stdio.h>

#ifdef SF_HAS_FLOAT
#include<float/float.h>
#endif

void print_stacks(char* st, char* rst) {
    cell* stp = (void*)st;
    ucell* rstp = (void*)rst;
    printf("%p\t%p\tSTACK\r\n", sf_header.stack_ptr, stp);
    --stp;
    while(stp >= (cell*)sf_header.stack_ptr) {
        printf("%li\t%lx\t%li\r\n", stp - (cell*)sf_header.stack_ptr, *stp, *stp);
        --stp;
    }
    printf("%p\t%p\tRETURN STACK\r\n", sf_header.return_stack_ptr, rstp);
    while(rstp < (ucell*)sf_header.return_stack_ptr) {
        printf("%li\t%lx\r\n", (ucell*)sf_header.return_stack_ptr - rstp, *rstp);
        ++rstp;
    }
#ifdef SF_HAS_FLOAT
    print_fstack();
#endif
}

udcell dummy_abort(char* st, char* rst) {
    print_stacks(st, rst);
    exit(1);
    return 0;
}
