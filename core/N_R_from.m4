define({N_R_from_body}, {
    stack_rpop a3
    stack_rpop a0
    mv a1, a0
.N_R_from_start:
    blez a0, .N_R_from_end
    stack_rpop a2
    stack_push a2
    add_acc_imm a0, -1
    j .N_R_from_start
.N_R_from_end:
    stack_push a1
    stack_rpush a3
    ret
})
