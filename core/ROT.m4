define({ROT_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_fetch a2, 3
    stack_store a2, 1
    stack_store a0, 2
    stack_store a1, 3
    ret
})
