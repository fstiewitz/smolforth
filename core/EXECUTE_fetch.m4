define({EXECUTE_fetch_body}, {
.defer_call:
    stack_rpush_ra
    stack_pop a0
    REG_L a0, 0(a0)
    stack_push a0
    call FORTH$body$EXECUTE
    stack_rpop_ra
    ret
})
