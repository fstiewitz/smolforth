define({D_plus_body}, {
    stack_fetch a1, 1
    stack_fetch a0, 2
    stack_fetch a3, 3
    stack_fetch a2, 4
    add_to a4, a0, a2
    set_clear a2
    sltu ba2, a4, a0
    add_to a0, a1, a3
    add_acc a0, a2
    stack_shrink 2
    stack_store a0, 1
    stack_store a4, 2
    ret
})
