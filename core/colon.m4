define({colon_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_pop a0
  lb a1, 0(a0)
  beqz a1, .colon_abort
  add_acc_imm a0, 1
  li a2, 0
  push_adata a3, sf_sys_CDATA
  stack_prepare
  call make_word
  call colon_enter
  stack_restore
  pop_adata a3
  stack_rpop_ra
  ret
.colon_abort:
  li a0, -16
  stack_push a0
  call FORTH$body$THROW
})
