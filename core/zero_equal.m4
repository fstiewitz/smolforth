define({zero_equal_body}, {
    stack_fetch a0, 1
    beqz a0, .bin_op_true
    j .bin_op_false
})
