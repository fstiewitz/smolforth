define({CHAR_plus_body}, {
    stack_fetch a0, 1
    add_acc_imm a0, 1
    stack_store a0, 1
    ret
})
