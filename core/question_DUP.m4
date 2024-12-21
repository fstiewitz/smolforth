define({question_DUP_body}, {
    stack_fetch a0, 1
    beqz a0, .question_DUP_end
    stack_push a0
.question_DUP_end:
    ret
})
