define({F_to_R_body}, {
    stack_fpop fa0
    mv_f_r a0, fa0
    stack_push a0
    ret
})
