define({plus_store_body}, {
  stack_fetch a0, 1
  stack_fetch a1, 2
  stack_shrink 2
  REG_L a2, (a0)
  add_acc a2, a1
  REG_S a2, 0(a0)
  ret
})
