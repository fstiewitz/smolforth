define({SPACES_body}, {
    stack_rpush_ra
    stack_pop a0
    li a1, 32
    bltz a0, .SPACES_end
.SPACES_start:
    beqz a0, .SPACES_end
    add_acc_imm a0, -1
    stack_push a0
    stack_push a1
    stack_push a1
    call FORTH$body$EMIT
    stack_pop a1
    stack_pop a0
    j .SPACES_start
.SPACES_end:
    stack_rpop_ra
    ret
})
