define({REPEAT_body}, {
    stack_rpush_ra
    call FORTH$body$AGAIN
    call FORTH$body$THEN
    stack_rpop_ra
    ret
})
