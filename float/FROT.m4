define({FROT_body}, {
    stack_ffetch fa0, 1
    stack_ffetch fa1, 2
    stack_ffetch fa2, 3
    stack_fstore fa2, 1
    stack_fstore fa0, 2
    stack_fstore fa1, 3
    ret
})
