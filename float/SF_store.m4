define({SF_store_body}, {
    stack_fpop fa0
    stack_pop a0
    SFREG_S fa0, 0(a0)
    ret
})
