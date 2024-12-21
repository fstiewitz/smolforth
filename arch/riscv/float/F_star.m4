define({F_star_body}, {
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    fmulx fa2, fa0, fa1
ifdef({IEEE754_2008}, {
    nan_propagate fa2, fa0, fa1, a0
}, {})
    stack_fpush fa2
    ret
})
