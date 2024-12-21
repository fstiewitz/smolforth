define({PICK_body}, {
    stack_pop a0
    sll_acc_imm a0, WSHM
    mv a1, s0
    sub_acc a1, a0
    REG_L a0, -WORDSIZE(a1)
    stack_push a0
    ret
})
