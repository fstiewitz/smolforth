define({FALOG_body}, {
    stack_rpush_ra
    fli fa0, 10, a0
    stack_fpop fa1
    stack_prepare
    call powx
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})
