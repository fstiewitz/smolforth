define({ALLOCATE_body}, {
  stack_rpush_ra
  stack_prepare
  stack_pop a0
  call malloc
  mv a1, ra0
  stack_restore
  stack_push a1
  li a0, 0
  bnez a1, .ALLOCATE_good
  li a0, -1
.ALLOCATE_good:
  stack_push a0
  stack_rpop_ra
  ret
})
