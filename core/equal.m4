define({equal_body}, {
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
})
