#include<asm-def.S>

.section .text

FORTH$body$FILL:
.globl FORTH$body$FILL
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_fetch a2, 3
    stack_shrink 3
.FILL_start:
    beqz a1, .FILL_end
    sb ba0, 0(a2)
    add_acc_imm a2, 1
    add_acc_imm a1, -1
    j .FILL_start
.FILL_end:
    ret

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

FORTH$body$equals:
.set "FORTH$body$=", FORTH$body$equals
.globl "FORTH$body$="
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 1
    beq a0, a1, .bin_op_true
    j .bin_op_false

.bin_op_true:
    li a0, -1
    stack_store a0, 1
    ret
.bin_op_false:
    stack_store x0, 1
    ret

FORTH$body$not_zero:
.set "FORTH$body$0<>", FORTH$body$not_zero
.globl "FORTH$body$0<>"
    stack_fetch a0, 1
    beqz a0, .bin_op_false
    j .bin_op_true

FORTH$body$slash_STRING:
.set "FORTH$body$/STRING", FORTH$body$slash_STRING
.globl "FORTH$body$/STRING"
    stack_fetch a0, 1 # n
    stack_fetch a1, 2 # len
    stack_fetch a2, 3 # c-addr
    stack_shrink 1
    add a2, a2, a0
    sub a1, a1, a0
    stack_store a1, 1 # len
    stack_store a2, 2 # c-addr
    ret
