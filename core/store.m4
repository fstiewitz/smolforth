define({store_body}, {
  stack_fetch a0, 1
  stack_fetch a1, 2
  stack_shrink 2
  REG_S a1, 0(a0)
  ret
})
