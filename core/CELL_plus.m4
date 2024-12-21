define({CELL_plus_body}, {
    stack_fetch a0, 1
    add_acc_imm a0, WORDSIZE
    stack_store a0, 1
    ret
})
