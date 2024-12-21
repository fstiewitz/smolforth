define({DF_fetch_body}, {
    stack_pop a0
    DFREG_L fa0, 0(a0)
    stack_fpush fa0
    ret
})
