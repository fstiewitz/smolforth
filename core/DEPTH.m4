define({DEPTH_body}, {
    REG_L_var a0, sf_sys_STACK_PTR
    mv a1, s0
    sub_acc a1, a0
    srl_acc_imm a1, WSHM
    stack_push a1
    ret
})
