define({number_bracket_body}, {
    stack_shrink 2
    la a0, sf_sys_PO
    lbu a1, 0(a0)
    add_to a2, a0, a1
    stack_push a2
    li a2, 255
    sub_acc a2, a1
    stack_push a2
    ret
})
