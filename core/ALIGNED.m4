define({ALIGNED_body}, {
    stack_pop a1
    and_to_imm a2, a1, WORDSIZE_ALIGN_MASK
    beqz a2, .align_end
    li a3, WORDSIZE_ALIGN_MASK
    inv_acc a3
    and_acc a3, a1
    add_to_imm a1, a3, WORDSIZE
.align_end:
    stack_push a1
    ret
})
