define({C_comma_body}, {
  stack_pop a0
  read_here a1
  sb ba0, 0(a1)
  add_acc_imm a1, 1
  write_here a1
  ret
})
