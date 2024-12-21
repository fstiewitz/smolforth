define({FSINCOS_body}, {
    stack_rpush_ra
    stack_ffetch fa0, 1
    stack_prepare
    call sinx
    stack_ffetch fa1, 1
    stack_fstore fa0, 1
    mv_f_f fa0, fa1
    call cosx
    stack_fstore fa0, 0
    stack_fgrow 1
    stack_restore
    stack_rpop_ra
    ret
})
