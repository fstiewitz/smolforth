define({F_zero_less_than_body}, {
    fninit
    fldz
    stack_fpop0
    fcomip
    set_clear a0
    setb ba0
    stack_grow 1
    beqz a0, .bin_op_false
    j .bin_op_true
})
