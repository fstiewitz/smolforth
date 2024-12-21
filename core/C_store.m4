define({C_store_body}, {
  stack_fetch a0, 1
  stack_fetch a1, 2
  stack_shrink 2
  sb ba1, 0(a0)
  ret
})
