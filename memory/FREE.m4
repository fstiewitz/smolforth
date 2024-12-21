define({FREE_body}, {
  stack_rpush_ra
  stack_prepare
  stack_pop a0
  call free
  stack_restore
  li a0, 0
  stack_push a0
  stack_rpop_ra
  ret
})
