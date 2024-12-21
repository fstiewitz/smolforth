define({one_plus_body}, {
    stack_pop a0
    add_acc_imm a0, 1
    stack_push a0
    ret
})
