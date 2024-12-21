define({ISNAN_question_body}, {
    stack_fpop fa0
    fclassx a0, fa0
    andi a0, a0, 0x300
    stack_grow 1
    beqz a0, .bin_op_false
    j .bin_op_true
})
