define({two_store_body}, {
  stack_fetch a0, 1
  stack_fetch a1, 2
  stack_fetch a2, 3
  stack_shrink 3
  REG_S a2, WORDSIZE(a0)
  REG_S a1, 0(a0)
  ret
})
