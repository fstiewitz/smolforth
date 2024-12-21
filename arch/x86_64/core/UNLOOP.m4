define({UNLOOP_body}, {
    stack_rpop a0
    rstack_shrink 2
    stack_rpush a0
    ret
})
