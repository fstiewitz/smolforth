define({F_slash_body}, {
    stack_ffetch fa1, 1
    stack_ffetch fa0, 2
    stack_fshrink 2
    divsd fa1, fa0
    stack_fpush fa0
    ret
})
