define({FLOOR_body}, {
    stack_rpush_ra
    stack_fpop fa0
    stack_prepare
    call floorx
    stack_restore
    stack_fpush fa0
    stack_rpop_ra
    ret
})
