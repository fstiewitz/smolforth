define({FATAN2_body}, {
    stack_rpush_ra
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    stack_prepare
    call atan2x
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})
