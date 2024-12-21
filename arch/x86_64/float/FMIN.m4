define({FMIN_body}, {
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    minsd fa0, fa1
    stack_fpush fa1
    ret
})
