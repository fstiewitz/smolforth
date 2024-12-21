define({paren_body}, {
    stack_rpush_ra
.paren_start0:
    REG_L_var a0, FORTH$body$PAO
    read_line_ptr a1
    read_line_size a2
.paren_start:
    beq a0, a2, .paren_end
    bgt a0, a2, .paren_end
    add_to a3, a1, a0
    lb a4, 0(a3)
    li a5, 41
    add_acc_imm a0, 1
    beq a4, a5, .paren_good
    j .paren_start
.paren_end:
    REG_S_var a0, FORTH$body$PAO
    read_source_id a0
    blez a0, .paren_ret
    call FORTH$body$REFILL
    stack_pop a0
    REG_S_var x0, FORTH$body$PAO
    beqz a0, .paren_ret
    j .paren_start0
.paren_good:
    REG_S_var a0, FORTH$body$PAO
.paren_ret:
    stack_rpop_ra
    ret
})
