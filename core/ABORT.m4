define({ABORT_body}, {
    li a0, -1
    stack_push a0
    simple_tail FORTH$body$THROW
})
