define({VARIABLE_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_pop a0
  lb a1, 0(a0)
  beqz a1, .VARIABLE_abort
  add_acc_imm a0, 1
  li a2, W_ADDR
  push_adata a3, sf_sys_UIDATA
  stack_prepare
  call make_word
  call forward_word
  stack_restore
  read_here a0
  add_acc_imm a0, WORDSIZE
  write_here a0
  pop_adata a3
  stack_rpop_ra
  ret
.VARIABLE_abort:
  li a0, -16
  stack_push a0
  call FORTH$body$THROW
})
