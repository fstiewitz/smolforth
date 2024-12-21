define({CLOSE_FILE_body}, {
  stack_rpush_ra
  stack_prepare
  stack_pop a0
  call close
  li a0, 0
  stack_push a0
  stack_restore
  stack_rpop_ra
  ret
})
