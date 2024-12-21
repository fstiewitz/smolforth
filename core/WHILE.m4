define({WHILE_body}, {
    stack_rpush_ra
    call FORTH$body$IF
    li a0, 1
    stack_push a0
    call FORTH$body$CS_ROLL
    stack_rpop_ra
    ret
})
