define({FSIN_body}, {
    stack_rpush_ra
    stack_fpop fa0
    stack_prepare
    call sinx
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})
