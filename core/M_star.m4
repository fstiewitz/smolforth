define({M_star_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    mul2_to_a2 a3, a0, a1
    stack_store a2, 1
    stack_store a3, 2
    ret
})
