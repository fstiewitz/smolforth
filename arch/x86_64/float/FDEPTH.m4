define({FDEPTH_body}, {
    mv a0, s2
    la a1, float_stack
    sub_acc a0, a1
    srl_acc_imm a0, WSHM
    stack_push a0
    ret
})
