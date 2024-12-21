define({R_from_body}, {
    stack_rpop a1
    stack_rpop a0
    stack_push a0
    stack_rpush a1
    ret
})
