define({greater_than_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 1
    blt a0, a1, .bin_op_true
    j .bin_op_false
})
