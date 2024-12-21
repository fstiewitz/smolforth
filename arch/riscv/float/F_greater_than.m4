define({F_greater_than_body}, {
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    flex a0, fa0, fa1
    stack_grow 1
    bnez a0, .bin_op_false
    j .bin_op_true
})
