define({F_star_star_body}, {
    stack_rpush_ra
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    stack_prepare
    call powx
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})
