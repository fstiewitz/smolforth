define({F_store_body}, {
    stack_fpop fa0
    stack_pop a0
    FREG_S fa0, 0(a0)
    ret
})
