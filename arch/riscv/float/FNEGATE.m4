define({FNEGATE_body}, {
    stack_fpop fa0
    fnegx fa0, fa0
    stack_fpush fa0
    ret
})
