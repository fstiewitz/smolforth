define({star_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    mul_to a2, a0, a1
    stack_shrink 1
    stack_store a2, 1
    ret
})
