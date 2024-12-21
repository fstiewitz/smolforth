define({ALIGN_body}, {
    stack_rpush_ra
    read_here a0
    stack_push a0
    call FORTH$body$ALIGNED
    stack_pop a0
    write_here a0
    stack_rpop_ra
    ret
})
