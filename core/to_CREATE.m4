define({to_CREATE_body}, {
  stack_rpush_ra
  stack_pop a1
  stack_pop a0
  li a2, W_CREATE
  li a3, 0
  stack_prepare
  call make_word
  call forward_word
  stack_restore
  stack_rpop_ra
  ret
})
