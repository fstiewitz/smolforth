define({F_less_than_body}, {
    fninit
    stack_ffetch0 1
    stack_ffetch0 2
    stack_fshrink 2
    fcomip %st(1), %st
    set_clear a0
    set_clear a1
    setb ba0
    setp ba1
    stack_grow 1
    bnez a1, .bin_op_false
    beqz a0, .bin_op_false
    j .bin_op_true
})
