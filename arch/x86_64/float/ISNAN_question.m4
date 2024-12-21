define({ISNAN_question_body}, {
    fninit
    stack_fpop0
    fldz
    fcomip %st(1), %st
    set_clear a0
    setp ba0
    stack_grow 1
    beqz a0, .bin_op_false
    j .bin_op_true
})
