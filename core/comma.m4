define({comma_body}, {
  stack_pop a0
  read_here a1
  REG_S a0, 0(a1)
  add_acc_imm a1, WORDSIZE
  write_here a1
  ret
})
