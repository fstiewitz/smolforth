#include <config.h>
#include "asmgen_riscv.h"

void colon_enter() {
    sf_header.state = 1;
    asmgen_SX(RA, S1, 0, &sf_header.cdata->here);
    asmgen_ADDI(S1, S1, sizeof(cell), &sf_header.cdata->here);
}

void* colon_exit() {
    asmgen_ADDI(S1, S1, -(int) sizeof(cell), &sf_header.cdata->here);
    asmgen_LX(RA, S1, 0, &sf_header.cdata->here);
    asmgen_JALR(X0, RA, 0, &sf_header.cdata->here);

    sf_header.state = 0;
    return forward_word();
}
