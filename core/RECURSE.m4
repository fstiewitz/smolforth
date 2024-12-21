define({RECURSE_body}, {
    la a0, next_word
    REG_L a0, (a0)
    stack_push a0
    simple_tail FORTH$body$COMPILE_comma
})
