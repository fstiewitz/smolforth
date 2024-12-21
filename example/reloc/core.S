# TUT Our fmain.fth uses four words, two are defined here, two in main.c
# TUT Notice that the actual code uses macros defined in `asm.S` (and `arch/.../asm-def.S`).
# TUT Platform-agnostic words are written entirely with these macros. Of course,
# TUT this code uses the x86_64 assembler, so you don't have to use them.
# TUT
# TUT You can now read `example/reloc/main.c`.

#include<asm.S>

.section .text

FORTH$body$dot:
.set "FORTH$body$.", FORTH$body$dot
.globl "FORTH$body$."
    la a0, .dot_str
    stack_pop a1
    stack_prepare
    call printf
    stack_restore
    ret

FORTH$body$fetch:
.set "FORTH$body$@", FORTH$body$fetch
.globl "FORTH$body$@"
    stack_pop a0
    REG_L a0, 0(a0)
    stack_push a0
    ret

.section .data

.dot_str:
.asciz "%li "
