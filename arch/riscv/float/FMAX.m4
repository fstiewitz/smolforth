define({FMAX_body}, {
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    fmaxx fa0, fa0, fa1
    stack_fpush fa0
    ret
})
