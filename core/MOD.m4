define({MOD_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    rem_to_clears_a2 a3, a1, a0
    stack_shrink 1
    stack_store a3, 1
    ret
})
