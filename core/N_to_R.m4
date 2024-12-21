define({N_to_R_body}, {
    stack_rpop a3
    stack_pop a0
    mv a1, a0
.N_to_R_start:
    blez a0, .N_to_R_end
    stack_pop a2
    stack_rpush a2
    add_acc_imm a0, -1
    j .N_to_R_start
.N_to_R_end:
    stack_rpush a1
    stack_rpush a3
    ret
})
