define({ACCEPT_body}, {
    stack_rpush_ra
    stack_push x0
.ACCEPT_start:
    stack_fetch a0, 2
    blez a0, .ACCEPT_flush
    li a0, 0
    la a1, .REFILL_char
    li a2, 1
    stack_prepare
    call read
    stack_restore
    blez ra0, .ACCEPT_end
    lb_var ba0, .REFILL_char
    li a1, 10
    beq a0, a1, .ACCEPT_end
    li a1, 3
    beq a0, a1, .ACCEPT_int
    li a1, 32
    blt a0, a1, .ACCEPT_start
    li a1, 127
    bne a0, a1, .ACCEPT_emit

    stack_fetch a1, 2
    blez a1, .ACCEPT_start
    add_acc_imm a1, 1
    stack_store a1, 2

    stack_fetch a1, 3
    add_acc_imm a1, -1
    stack_store a1, 3

    stack_fetch a1, 1
    add_acc_imm a1, -1
    stack_store a1, 1

    li a0, 1
    la a1, .delete_esc_str
    li a2, 7
    stack_prepare
    call write
    stack_restore

    j .ACCEPT_start
.ACCEPT_emit:
    stack_push a0
    stack_prepare
    li a0, 1
    la a1, .REFILL_char
    li a2, 1
    call write
    stack_restore
    stack_pop a0
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
    j .ACCEPT_start
.ACCEPT_flush:
    la a0, stdin
    REG_L a0, (a0)
    stack_prepare
    call fgetc
    mv a0, ra0
    stack_restore
    blez a0, .ACCEPT_end
    li a1, 10
    beq a0, a1, .ACCEPT_end
    j .ACCEPT_flush
.ACCEPT_end:
    stack_fetch a0, 1
    stack_shrink 2
    stack_store a0, 1
    call FORTH$body$CR
    stack_rpop_ra
    ret

.ACCEPT_int:
    stack_shrink 3
    li a0, 0
    stack_push a0
    call FORTH$body$CR
    stack_rpop_ra
    ret

.delete_esc_str:
.ascii "\033[D \033[D"
})
