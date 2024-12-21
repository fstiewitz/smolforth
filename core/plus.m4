define({plus_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    add_acc a0, a1
    stack_store a0, 2
    stack_shrink 1
    ret
})
