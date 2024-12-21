define({CONSTANT_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_pop a0
  lb a1, 0(a0)
  beqz a1, .CONSTANT_abort
  add_acc_imm a0, 1
  li a2, W_CONSTANT
  push_adata a3, sf_sys_IDATA
  stack_prepare
  call make_word
  call forward_word
  stack_restore
  pop_adata a3
  stack_pop a1
  push_adata a3, sf_sys_IDATA
  read_here a0
  REG_S a1, 0(a0)
  add_acc_imm a0, WORDSIZE
  write_here a0
  pop_adata a3
  stack_rpop_ra
  ret
.CONSTANT_abort:
  li a0, -16
  stack_push a0
  call FORTH$body$THROW
})
