define({CATCH_body}, {
    stack_rpush_ra

    stack_rpush s0
    REG_L_var a0, sf_sys_HANDLER
    stack_rpush a0
    REG_S_var s1, sf_sys_HANDLER

    la a1, sf_sys_ERRNO
    REG_S x0, 0(a1)

    call FORTH$body$EXECUTE

    stack_rpop a0
    REG_S_var a0, sf_sys_HANDLER
    stack_rpop a1

    li a0, 0
    stack_push a0

    stack_rpop_ra
    ret
})
