define({FSQRT_body}, {
    stack_fpop fa0
    fsqrtx fa2, fa0
ifdef({IEEE754_2008}, {
    nan_propagate1 fa2, fa0, a0
}, {})
    stack_fpush fa2
    ret
})
