define({ELSE_body}, {
    stack_rpush_ra
    call FORTH$body$AHEAD
    li a0, 1
    stack_push a0
    call FORTH$body$CS_ROLL
    call FORTH$body$THEN
    stack_rpop_ra
    ret
})
