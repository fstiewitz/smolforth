define({DOES_to_body}, {
        stack_rpush_ra
        la a0, FORTH$SYS_DOES_to
        stack_push a0
        call FORTH$body$COMPILE_comma
        stack_rpop_ra
        simple_tail DOES_to_impl
})
