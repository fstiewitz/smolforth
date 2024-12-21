define({FSQRT_body}, {
    stack_fpop fa0
    sqrtsd fa0, fa1
    stack_fpush fa1
    ret
})
