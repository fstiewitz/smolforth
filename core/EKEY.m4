define({EKEY_body}, {
    stack_rpush_ra
    la a0, stdin
    REG_L a0, (a0)
    stack_prepare
    call fgetc
    mv a0, ra0
    stack_restore
    stack_push a0
    stack_rpop_ra
    ret
})
