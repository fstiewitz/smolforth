define({EMIT_body}, {
    stack_rpush_ra
    stack_pop a0
    la a1, stdout
    REG_L a1, (a1)
    stack_prepare
    call fputc
    la a0, stdout
    REG_L a0, (a0)
    call fflush
    stack_restore
    stack_rpop_ra
    ret
})
