define({REFILL_body}, {
  stack_rpush_ra
  read_blk a0
  read_source_id a1
ifdef({SF_HAS_BUILTIN_BLOCK}, {
  bnez a0, .REFILL_inc_block
}, {
  bnez a0, .REFILL_false
})
  bltz a1, .REFILL_false
  beqz a1, .REFILL_terminal
  // REFILL file
  la a0, FORTH$body$LINE_BUFFER
  stack_push a0
  li a0, LINEBUFSIZE-1
  stack_push a0
  stack_push x0
.REFILL_start: // lbuf lsize ix
    stack_fetch a0, 2
    blez a0, .REFILL_flush
    read_source_id a0
    la a1, .REFILL_char
    li a2, 1
    stack_prepare
    call read
    stack_restore
    li a1, -1
    beq ra0, a1, .REFILL_err
    beqz ra0, .REFILL_err
    lb_var ba0, .REFILL_char
    blez a0, .REFILL_end
    li a1, 10
    beq a0, a1, .REFILL_end
    li a1, 13
    beq a0, a1, .REFILL_end
    stack_fetch a1, 3
    sb ba0, 0(a1)
    add_acc_imm a1, 1
    stack_store a1, 3
    stack_fetch a0, 2
    add_acc_imm a0, -1
    stack_store a0, 2
    stack_fetch a0, 1
    add_acc_imm a0, 1
    stack_store a0, 1
    j .REFILL_start
.REFILL_flush:
    read_source_id a0
    la a1, .REFILL_char
    li a2, 1
    stack_prepare
    call read
    stack_restore
    li a1, -1
    beq ra0, a1, .REFILL_err
    beqz ra0, .REFILL_end
    lb_var ba0, .REFILL_char
    blez a0, .REFILL_end
    li a1, 10
    beq a0, a1, .REFILL_end
    li a1, 13
    beq a0, a1, .REFILL_end
    j .REFILL_flush
.REFILL_end:
    stack_fetch a0, 1
    stack_fetch a1, 3
    sub_acc a1, a0
    write_line_ptr a1
    write_line_size a0
    add_acc a1, a0
    sb x0, 0(a1)
    stack_shrink 2
    li a0, -1
    stack_store a0, 1
    li a0, 0
    REG_S_var a0, FORTH$body$PAO
    stack_rpop_ra
    ret

.REFILL_terminal:
    la a0, FORTH$body$LINE_BUFFER
    stack_push a0
    li a0, LINEBUFSIZE-1
    stack_push a0
    la a0, FORTH$ACCEPT
    stack_push a0
    call FORTH$body$CATCH
    stack_pop a1
    bnez a1, .REFILL_false
    stack_pop a0
    la a1, FORTH$body$LINE_BUFFER
    write_line_ptr a1
    write_line_size a0
    li a0, -1
    stack_push a0
    stack_rpop_ra
    ret

.REFILL_err:
    stack_shrink 3
.REFILL_false:
    stack_push x0
    stack_rpop_ra
    ret

ifdef({SF_HAS_BUILTIN_BLOCK}, {
.REFILL_inc_block:
    add_acc_imm a0, 1
    write_blk a0
    li a1, 0
    REG_S_var a1, FORTH$body$PAO
    stack_push a0
    call FORTH$body$BLOCK
    stack_pop a0
    beqz a0, .REFILL_false
    write_line_ptr a0
    li a1, 1024
    write_line_size a1
    li a0, -1
    stack_push a0
    stack_rpop_ra
    ret
}, {})

.REFILL_char:
.byte 0
})
