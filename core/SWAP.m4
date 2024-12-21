define({SWAP_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_store a1, 1
    stack_store a0, 2
    ret
})
