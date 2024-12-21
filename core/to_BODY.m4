define({to_BODY_body}, {
    stack_rpush_ra
    stack_pop a0
    stack_prepare
    call to_body
    stack_restore
    stack_push ra0
    stack_rpop_ra
    ret
})
