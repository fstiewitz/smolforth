#include<config.h>
#include<float/float.h>

fcell float_stack[8];
fcell *fps = float_stack;

void fpush(fcell x) {
    *(fps++) = x;
}

fcell fpop() {
    return *(--fps);
}
