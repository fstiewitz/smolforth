define({F_fetch_body}, {
    stack_pop a0
    FREG_L fa0, 0(a0)
    stack_fpush fa0
    ret
})
