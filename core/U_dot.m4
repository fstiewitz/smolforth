define({U_dot_body}, {
    stack_rpush_ra
    li a0, 0
    stack_push a0
    call FORTH$body$bracket_number
    call FORTH$body$number_sign_S
    call FORTH$body$number_bracket
    call FORTH$body$TYPE
    call FORTH$body$SPACE
    stack_rpop_ra
    ret
})
