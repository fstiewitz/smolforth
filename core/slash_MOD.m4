define({slash_MOD_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    div2_to_a2 a3, a1, a0
    stack_store a3, 1
    stack_store a2, 2
    ret
})
