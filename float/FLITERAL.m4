define({FLITERAL_body}, {
  stack_rpush_ra
  stack_push x0
  defer_call FORTH$COMPILE_FCONSTANT
  stack_rpop_ra
  ret
})
