define({F_zero_equal_body}, {
    fninit
    fldz
    stack_fpop0
    fcomip
    set_clear a0
    sete ba0
    stack_grow 1
    beqz a0, .bin_op_false
    j .bin_op_true
})
