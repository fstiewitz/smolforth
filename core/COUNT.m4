define({COUNT_body}, {
    stack_fetch a0, 1
    lb a1, 0(a0)
    add_acc_imm a0, 1
    stack_store a0, 1
    stack_store a1, 0
    stack_grow 1
    ret
})
