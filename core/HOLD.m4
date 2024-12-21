define({HOLD_body}, {
    stack_pop a0
    la a1, sf_sys_PO
    lbu a2, 0(a1)
    add_acc_imm a2, -1
    beqz a2, .HOLD_error
    bltz a2, .HOLD_error
    add_to a3, a1, a2
    sb ba0, 0(a3)
    sb ba2, 0(a1)
    ret
.HOLD_error:
    ret
})
