define({number_sign_S_body}, {
    stack_rpush_ra
.number_sign_S_start:
    call FORTH$body$number_sign
    stack_fetch a0, 1
    stack_fetch a1, 2
    or_acc a0, a1
    beqz a0, .number_sign_S_end
    j .number_sign_S_start
.number_sign_S_end:
    stack_rpop_ra
    ret
})
