define({MAX_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 1
    blt a1, a0, .choose_a0
    mv a0, a1
    j .choose_a0
})
