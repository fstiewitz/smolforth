define({FALOG_body}, {
    stack_rpush_ra
    li a0, 10
    cvtsi2sd a0, fa0
    stack_fpop fa1
    stack_prepare
    call pow
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})
