#include <config.h>

#include <stdlib.h>
#include <stdio.h>

#ifdef SF_HAS_FLOAT
#include<float/float.h>
#endif

void print_stacks(char* st, char* rst) {
    cell* stp = (void*)st;
    ucell* rstp = (void*)rst;
    printf("%p\t%p\tSTACK\n", (cell*)sf_header.stack_ptr, stp);
    --stp;
    int i = 0;
    while(stp >= (cell*)sf_header.stack_ptr) {
        printf("%li\t%lx\t%li\n", i++, *stp, *stp);
        --stp;
    }
    printf("%p\tRETURN STACK\n", sf_header.return_stack_ptr);
    --rstp;
    while(rstp >= (ucell*)sf_header.return_stack_ptr) {
        printf("%li\t%lx\n", rstp - (ucell*)sf_header.return_stack_ptr, *rstp);
        --rstp;
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
