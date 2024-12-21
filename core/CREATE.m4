define({CREATE_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_pop a0
  lb a1, 0(a0)
  beqz a1, .CREATE_abort
  add_acc_imm a0, 1
  li a2, W_CREATE
  li a3, 0
  stack_prepare
  call make_word
  call forward_word
  stack_restore
  stack_rpop_ra
  ret
.CREATE_abort:
  li a0, -16
  stack_push a0
  call FORTH$body$THROW
})
