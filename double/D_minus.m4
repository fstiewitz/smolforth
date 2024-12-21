define({D_minus_body}, {
    stack_fetch a1, 1
    stack_fetch a0, 2
    stack_fetch a4, 3
    stack_fetch a3, 4
    stack_shrink 2
    sub_to a5, a3, a0
    stack_store a5, 2
    set_clear a2
    sltu ba2, a3, a0
    sub_to a0, a4, a1
    sub_acc a0, a2
    stack_store a0, 1
    ret
})
