define({FSWAP_body}, {
    stack_ffetch fa0, 1
    stack_ffetch fa1, 2
    stack_fstore fa1, 1
    stack_fstore fa0, 2
    ret
})
