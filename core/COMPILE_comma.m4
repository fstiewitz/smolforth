define({COMPILE_comma_body}, {
    stack_rpush_ra
    stack_fetch a0, 1
    call to_body
    mv a0, ra0
    stack_pop a1
    lb a2, -1(a1)
    /* a: body, xt, flags */

    /* test for constant */
    and_to_imm a3, a2, W_CONSTANT
    beqz a3, .compile_maybe_addr
    REG_L a3, (a0)
    stack_push a0
    stack_push a2
    stack_push a1
    stack_push a1
    stack_push a3
    defer_call FORTH$COMPILE_CONSTANT
    stack_pop a1
    stack_pop a2
    stack_pop a0
    j .compile_maybe_exec

.compile_maybe_addr:
    /* test for address */
    and_to_imm a3, a2, W_ADDR
    beqz a3, .compile_maybe_exec
    stack_push a2
    stack_push a1
    stack_push a0
    stack_push a1
    stack_push a0
    defer_call FORTH$COMPILE_ADDR
    stack_pop a0
    stack_pop a1
    stack_pop a2
    j .compile_maybe_exec

.compile_maybe_exec:
    /* check for execute */
    and_to_imm a3, a2, W_EXEC
    beqz a3, .compile_maybe_runtime
    REG_L a0, WORDSIZE(a1)
    beqz a0, .compile_end
.compile_exec:
    stack_rpop_ra
    stack_push a1
    stack_push a0
    defer_j FORTH$COMPILE_EXECUTE

.compile_maybe_runtime:
    /* check for runtime */
    and_to_imm a3, a2, W_RUNTIME
    beqz a3, .compile_maybe_run
.compile_runtime:
    REG_L a3, WORDSIZE(a1)
    beqz a3, .compile_maybe_run
    stack_rpop_ra
    simple_jmp_reg 0(a0)

.compile_maybe_run:
    and_to_imm a3, a2, W_PUSH_MASK
    bnez a3, .compile_end
    stack_rpop_ra
    stack_push a1
    stack_push a0
    defer_j FORTH$COMPILE_EXECUTE

.compile_end:
    stack_rpop_ra
    ret
})
