define({minus_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    sub_acc a0, a1
    neg_acc a0
    stack_store a0, 2
    stack_shrink 1
    ret
})
