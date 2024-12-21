define({number_sign_body}, {
    stack_rpush_ra
    call number_sign_c_impl
    call FORTH$body$HOLD
    stack_rpop_ra
    ret
})
