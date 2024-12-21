define({bracket_CHAR_body}, {
    stack_rpush_ra
    call FORTH$body$BL
    call FORTH$body$WORD
    stack_pop a0
    lb a1, 0(a0)
    beqz a1, .CHAR_error
    lb a1, 1(a0)
    stack_push x0
    stack_push a1
    stack_rpop_ra
    defer_j FORTH$COMPILE_CONSTANT
})
