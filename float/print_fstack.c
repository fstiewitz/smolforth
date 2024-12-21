#include<config.h>
#include<float/float.h>
#include<stdio.h>

void print_fstack() {
    printf("%p\t%p\tFLOAT STACK\r\n", float_stack, fps);
    while(float_stack < fps) {
        --fps;
        printf("%li\t%0*x\t%f\r\n", fps - float_stack, sizeof(ucell) * 2, *(ucell*)fps, *fps);
    }
    fflush(stdout);
}
