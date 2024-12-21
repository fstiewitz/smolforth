#include<asm-def.S>

.section .text

FORTH$does$plus_FIELD:
.set "FORTH$does$+FIELD", FORTH$does$plus_FIELD
.globl "FORTH$does$+FIELD"
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 1
    ld a0, 0(a0)
    add a0, a0, a1
    stack_store a0, 1
    ret

__udivti3:
.globl __udivti3
    ret

__umodti3:
.globl __umodti3
    ret
