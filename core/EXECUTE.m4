define({EXECUTE_body}, {
    stack_rpush_ra
    stack_fetch a0, 1
    call to_body
    mv a0, ra0
    stack_rpop_ra
    stack_pop a1
    lb a2, -1(a1)
    /* a: body, xt, flags */

    /* test for constant */
    and_to_imm a3, a2, W_CONSTANT
    beqz a3, .maybe_addr
    REG_L a3, (a0)
    stack_push a3
    j .maybe_exec

.maybe_addr:
    /* test for address */
    and_to_imm a3, a2, W_ADDR
    beqz a3, .maybe_exec
    stack_push a0
    j .maybe_exec

.maybe_exec:
    /* check for execute */
    and_to_imm a3, a2, W_EXEC
    beqz a3, .maybe_runtime
    REG_L a0, WORDSIZE(a1)
    beqz a0, .execute_end
    jr a0

.maybe_runtime:
    /* check for execute */
    and_to_imm a3, a2, W_RUNTIME
    beqz a3, .maybe_run
    REG_L a3, WORDSIZE(a1)
    beqz a3, .maybe_run
    jr a3

.maybe_run:
    and_to_imm a3, a2, W_PUSH_MASK
    bnez a3, .execute_end
    jr a0

.execute_end:
    ret
})
