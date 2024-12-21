define({TYPE_body}, {
    stack_rpush_ra
    stack_pop a1
    stack_pop a0
    li a2, 1
    la a3, stdout
    REG_L a3, (a3)
    stack_prepare
    call fwrite
    stack_restore
    stack_rpop_ra
    ret
})
