define({F_zero_equal_body}, {
    stack_fpop fa0
    fcvtx fa1, x0
    feqx a0, fa0, fa1
    stack_grow 1
    beqz a0, .bin_op_false
    j .bin_op_true
})
