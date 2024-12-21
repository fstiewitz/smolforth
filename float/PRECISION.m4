define({PRECISION_body}, {
    REG_L_var a0, F_precision
    stack_push a0
    ret

.balign WORDSIZE, 0
F_precision:
.globl F_precision
CELL 7
})
