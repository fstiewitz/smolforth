define({two_SWAP_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_fetch a2, 3
    stack_fetch a3, 4
    stack_store a2, 1
    stack_store a3, 2
    stack_store a0, 3
    stack_store a1, 4
    ret
})
