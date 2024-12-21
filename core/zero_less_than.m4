define({zero_less_than_body}, {
    stack_fetch a0, 1
    bltz a0, .bin_op_true
    j .bin_op_false
})
