define({two_fetch_body}, {
  stack_fetch a0, 1
  REG_L a2, (a0)
  REG_L a1, WORDSIZE(a0)
  stack_store a1, 1
  stack_store a2, 0
  stack_grow 1
  ret
})
