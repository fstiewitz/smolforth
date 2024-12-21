define({CELLS_body}, {
    stack_pop a0
    sll_acc_imm a0, WSHM
    stack_push a0
    ret
})
