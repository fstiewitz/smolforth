define({FABS_body}, {
    stack_fpop fa0
    fabsx fa0, fa0
    stack_fpush fa0
    ret
})
