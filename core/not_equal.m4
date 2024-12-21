define({not_equal_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 1
    beq a0, a1, .bin_op_false
    j .bin_op_true
})
