define({RESIZE_body}, {
  stack_rpush_ra
  stack_prepare
  stack_fetch a1, 1
  stack_fetch a0, 2
  call realloc
  mv a1, ra0
  stack_restore
  bnez a1, .RESIZE_good
  li a0, -1
  stack_store a0, 1
  stack_rpop_ra
  ret
.RESIZE_good:
  stack_store a1, 2
  li a0, 0
  stack_store a0, 1
  stack_rpop_ra
  ret
})
