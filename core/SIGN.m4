define({SIGN_body}, {
    stack_pop a0
    set_clear a1
    sltz ba1, a0
    beqz a1, .SIGN_end
    li a0, 45
    stack_push a0
    simple_tail FORTH$body$HOLD
.SIGN_end:
    ret
})
