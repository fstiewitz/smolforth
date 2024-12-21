#include<asm-def.S>

.section .text

__assert_fail:
.globl __assert_fail
    mv a4, a3
    mv a3, a2
    mv a2, a1
    mv a1, a0
    li a0, 1
    ecall
.L0:
    wfi
    j .L0
