define({THROW_body}, {
    stack_rpush_ra

    stack_pop a0
    beqz a0, .THROW_end

    la a1, sf_sys_ERRNO
    REG_S a0, 0(a1)

    REG_L_var s1, sf_sys_HANDLER
    stack_rpop a1
    REG_S_var a1, sf_sys_HANDLER

    stack_rpop s0
    stack_pop a1
    stack_push a0

.THROW_end:
    stack_rpop_ra
    ret
})
