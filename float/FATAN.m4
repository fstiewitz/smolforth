define({FATAN_body}, {
    stack_rpush_ra
    stack_fpop fa0
    stack_prepare
    call atanx
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})