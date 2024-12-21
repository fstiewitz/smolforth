#include <config.h>
#include "asmgen_x86_64.h"

void colon_enter() {
    sf_header.state = 1;
}

void* colon_exit() {
    asmgen_RET(&sf_header.cdata->here);

    sf_header.state = 0;
    return forward_word();
}
