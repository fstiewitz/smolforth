define({EVALUATE_RAW_body}, {
    stack_rpush_ra
    stack_fetch a0, 1
    stack_fetch a1, 2
    stack_shrink 2
    write_line_size a0
    write_line_ptr a1
    REG_S_var x0, FORTH$body$PAO

    call .EVALUATE_step
    stack_shrink 1
    li a0, 0
    la a1, sf_sys_ERRNO
    REG_S a0, 0(a1)
    stack_rpop_ra
    ret
})
