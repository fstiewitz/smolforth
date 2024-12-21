define({ALLOT_body}, {
    stack_pop a0
    read_here a1
    add_acc a0, a1
    write_here a0
    ret
})
