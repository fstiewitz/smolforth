define({C_fetch_body}, {
  stack_fetch a0, 1
  lbu a0, 0(a0)
  stack_store a0, 1
  ret
})
