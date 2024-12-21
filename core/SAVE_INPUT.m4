define({SAVE_INPUT_body}, {
    stack_rpush_ra
    call FORTH$body$DEPTH
    stack_pop a0
    stack_rpush a0
    read_line_size a0
    read_line_ptr a1
    stack_rpush a0
    stack_rpush a1
    read_blk a3
    read_source_id a4
    bnez a3, .SAVE_INPUT_end
    li a2, -1
    beq a2, a4, .SAVE_INPUT_end
.SAVE_INPUT_start:
    beqz a0, .SAVE_INPUT_end
    lb a2, 0(a1)
    stack_push a2
    add_acc_imm a0, -1
    add_acc_imm a1, 1
    j .SAVE_INPUT_start
.SAVE_INPUT_end:
ifdef({SF_HAS_FILE}, {
    blez a4, .SAVE_INPUT_ret
    stack_rpush a2
    stack_rpush a3
    stack_rpush a4

    stack_push a4
    call FORTH$body$FILE_POSITION
    stack_pop a4

    stack_rpop a4
    stack_rpop a3
    stack_rpop a2
}, {})
.SAVE_INPUT_ret:
    stack_rpop a1
    stack_rpop a0
    REG_L_var a2, FORTH$body$PAO
    stack_store a0, 0
    stack_store a1, -1
    stack_store a2, -2
    stack_store a3, -3
    stack_store a4, -4
    stack_grow 5
    call FORTH$body$DEPTH
    stack_pop a0
    stack_rpop a1
    sub_acc a0, a1
    stack_push a0
    stack_rpop_ra
    ret
})
