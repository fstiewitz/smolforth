define({SF_fetch_body}, {
    stack_pop a0
    SFREG_L fa0, 0(a0)
    stack_fpush fa0
    ret
})
