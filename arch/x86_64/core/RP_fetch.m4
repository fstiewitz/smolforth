define({RP_fetch_body}, {
    mv a0, s1
    add_acc_imm a0, WORDSIZE
    stack_push a0
    ret
})
