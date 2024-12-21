define({ABS_body}, {
    stack_fetch a0, 1
    bltz a0, .negate
    ret

.negate:
    neg_acc a0
    stack_store a0, 1
    ret
})
