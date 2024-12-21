define({LITERAL_body}, {
  stack_rpush_ra
  stack_pop a0
  stack_push x0
  stack_push a0
  defer_call FORTH$COMPILE_CONSTANT
  stack_rpop_ra
  ret
})
