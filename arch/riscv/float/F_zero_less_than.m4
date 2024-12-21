define({F_zero_less_than_body}, {
    stack_fpop fa0
    fcvtx fa1, x0
    fltx a0, fa0, fa1
    stack_grow 1
    beqz a0, .bin_op_false
    j .bin_op_true
})
