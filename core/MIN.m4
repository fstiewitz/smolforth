define({MIN_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 1
    blt a0, a1, .choose_a0
    mv a0, a1
    j .choose_a0

.choose_a0:
    stack_store a0, 1
    ret
})
