define({BYE_body}, {
  stack_rpush_ra
  stack_reset
  li a0, 1
  stack_rpop_ra
  ret
})
