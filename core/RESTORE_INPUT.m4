define({RESTORE_INPUT_body}, {
    stack_rpush_ra
    stack_shrink 6
    stack_fetch a0, 0
    stack_fetch a1, -1
    stack_fetch a2, -2
    stack_fetch a3, -3
    stack_fetch a4, -4
    write_line_size a0
    write_line_ptr a1
    REG_S_var a2, FORTH$body$PAO
    write_blk a3
    write_source_id a4
    add_acc a1, a0
    bnez a3, .RESTORE_INPUT_end
    li a2, -1
    beq a2, a4, .RESTORE_INPUT_end
ifdef({SF_HAS_FILE}, {
    beqz a4, .RESTORE_INPUT_start
    stack_rpush a0
    stack_rpush a1
    stack_rpush a2

    stack_push a4
    call FORTH$body$REPOSITION_FILE
    stack_pop a0

    stack_rpop a2
    stack_rpop a1
    stack_rpop a0
}, {})
.RESTORE_INPUT_start:
    beqz a0, .RESTORE_INPUT_end
    stack_pop a2
    sb ba2, -1(a1)
    add_acc_imm a0, -1
    add_acc_imm a1, -1
    j .RESTORE_INPUT_start
.RESTORE_INPUT_end:
    li a0, 0
    stack_push a0
    stack_rpop_ra
    ret
})
