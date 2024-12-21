define({two_OVER_body}, {
    stack_fetch a0, 3
    stack_fetch a1, 4
    stack_store a0, -1
    stack_store a1, 0
    stack_grow 2
    ret
})
