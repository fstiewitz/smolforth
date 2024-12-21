define({SYS_EXIT_body}, {
    stack_rpush_ra
    call SYS_EXIT_impl
    stack_rpush_ra
    ret
})
