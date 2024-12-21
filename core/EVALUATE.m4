define({EVALUATE_body}, {
    stack_rpush_ra
    call FORTH$body$SAVE_INPUT
    call FORTH$body$N_to_R

    li a5, -1
    write_source_id a5
    write_blk x0

    la a0, FORTH$EVALUATE_RAW
    stack_push a0
    call FORTH$body$CATCH
    stack_pop a0
    beqz a0, .EVALUATE_good

    stack_push a0

    call FORTH$body$N_R_from
    call FORTH$body$RESTORE_INPUT
    stack_shrink 1

    li a0, 0
    la a1, sf_sys_ERRNO
    REG_S a0, 0(a1)

    call FORTH$body$THROW

.EVALUATE_good:
    call FORTH$body$N_R_from
    call FORTH$body$RESTORE_INPUT
    stack_shrink 1
    // mv a0, s0
    // mv a1, s1
    // stack_prepare
    // call print_stacks
    // stack_restore
    li a0, 0
    la a1, sf_sys_ERRNO
    REG_S a0, 0(a1)
    stack_rpop_ra
    ret

.EVALUATE_step:
  stack_rpush_ra
.EVAL_ls:
    call FORTH$body$BL
    call FORTH$body$WORD
    stack_fetch a0, 1
    lb a0, 0(a0)
    beqz a0, .EVAL_le
    call .EVALUATE_internal
    j .EVAL_ls
.EVAL_le:
  stack_rpop_ra
  ret

.balign WORDSIZE, 0
unknown_word:
.globl unknown_word
  stack_rpop a1
  stack_rpop a0
  REG_S_var a1, sf_sys_ERR_SIZE
  REG_S_var a0, sf_sys_ERR_STR
  li a0, -13
  stack_push a0
  call FORTH$body$THROW

.EVALUATE_internal:
  stack_rpush_ra
  call FORTH$body$FIND
  stack_pop a0
  bnez a0, .EVALUATE_isword
  /* is number */
  call FORTH$body$COUNT
  stack_fetch a1, 1
  stack_fetch a0, 2
ifdef({SF_HAS_FLOAT}, {
  stack_rpush a0
  stack_rpush a1
  read_base a4
  li a5, 10
  bne a4, a5, .not_float
  li a4, 69
  li a5, 101
  mv a2, a0
.float_test_start:
  lb a3, 0(a2)
  beq a3, a4, .maybe_float
  beq a3, a5, .maybe_float
  add_acc_imm a2, 1
  add_to a3, a0, a1
  blt a2, a3, .float_test_start
.not_float:
}, {
  stack_rpush a0
  stack_rpush a1
})
  stack_shrink 2
  stack_store x0, -0
  stack_store x0, -1
  stack_store a0, -2
  stack_store a1, -3
  stack_grow 4
  call .to_SNUMBER
  stack_fetch a0, 1 /* len */
  stack_fetch a1, 2 /* c-addr */
  stack_fetch a2, 3 /* ud upper */
  stack_fetch a3, 4 /* ud lower */
  stack_shrink 4
  bnez a0, .maybe_double
  stack_rpop a4
  stack_rpop a5
  read_state a0
  beqz a0, .EVALUATE_push
.EVALUATE_onpushc:
  stack_store x0, 0
  stack_store a3, -1
  stack_grow 2
  stack_rpop_ra
  defer_j FORTH$COMPILE_CONSTANT
.EVALUATE_push:
  stack_push a3
  stack_rpop_ra
  ret
.EVALUATE_isword:
  stack_fetch a0, 1
  lb a1, -1(a0)
  and_acc_imm a1, W_IMMEDIATE
  read_state a0
  and_acc a1, a0
  seqz ba0, a0
  or_acc a0, a1
  stack_rpop_ra
  bnez a0, .EVALUATE_exec
  simple_tail FORTH$body$COMPILE_comma
.EVALUATE_exec:
  simple_tail FORTH$body$EXECUTE

ifdef({SF_HAS_FLOAT}, {
.maybe_float:
  call FORTH$body$to_FLOAT
  stack_pop a0
  beqz a0, unknown_word
  stack_rpop a4
  stack_rpop a5
  read_state a0
  beqz a0, .EVALUATE_float_push
  stack_push x0
  stack_rpop_ra
  defer_j FORTH$COMPILE_FCONSTANT
.EVALUATE_float_push:
  stack_rpop_ra
  ret
}, {})

.maybe_double:
  li a4, 1
  bne a4, a0, unknown_word
  lb a0, 0(a1)
  li a5, 46
  bne a0, a5, unknown_word
  stack_rpop a4
  stack_rpop a5
  li a4, 0
  bgez a3, .EVALUATE_dtest
  li a4, -1
.EVALUATE_dtest:
  read_state a0
  beqz a0, .EVALUATE_dpush
.EVALUATE_ondpushc:
  stack_push a4
  stack_store x0, 0
  stack_store a3, -1
  stack_grow 2
  defer_call FORTH$COMPILE_CONSTANT
  stack_pop a4
  stack_store x0, 0
  stack_store a4, -1
  stack_grow 2
  stack_rpop_ra
  defer_j FORTH$COMPILE_CONSTANT
.EVALUATE_dpush:
  stack_push a3
  stack_push a4
  stack_rpop_ra
  ret

.to_SNUMBER:
  stack_fetch a0, 1
  beqz a0, .normal_NUMBER /* is empty string? */
  stack_fetch a1, 2
  lb a2, 0(a1)
  li a3, 45
  bne a2, a3, .normal_NUMBER
  stack_rpush_ra /* is negative */
  add_acc_imm a0, -1
  beqz a0, .to_SNUMBER_err
  add_acc_imm a1, 1
  stack_store a0, 1
  stack_store a1, 2
  call FORTH$body$to_NUMBER
  stack_fetch a0, 4
  neg_acc a0
  stack_store a0, 4
.to_SNUMBER_err:
  stack_rpop_ra
  ret
.normal_NUMBER:
  simple_tail FORTH$to_NUMBER+WORDSIZE


})
