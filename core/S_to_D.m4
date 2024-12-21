define({S_to_D_body}, {
    stack_fetch a0, 1
    stack_grow 1
    bltz a0, .bin_op_true
    j .bin_op_false
})
