define({FILL_body}, {
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_fetch a2, 3
    stack_shrink 3
.FILL_start:
    beqz a1, .FILL_end
    sb ba0, 0(a2)
    add_acc_imm a2, 1
    add_acc_imm a1, -1
    j .FILL_start
.FILL_end:
    ret
})
