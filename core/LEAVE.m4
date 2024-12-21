define({LEAVE_body}, {
    stack_rpush_ra
    la a0, FORTH$SYS_LEAVE
    stack_push a0
    call FORTH$body$COMPILE_comma
    call FORTH$body$AHEAD
    stack_rpop_ra
    mv a0, s0
    mv a1, s1
    simple_tail cs_leave_impl
})
