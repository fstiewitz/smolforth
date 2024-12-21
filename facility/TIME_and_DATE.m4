define({TIME_and_DATE_body}, {
  stack_rpush_ra
  stack_prepare
  call TIME_and_DATE_impl
  stack_restore
  stack_pop a0
  beqz a0, .TIME_and_DATE_err
  stack_rpop_ra
  ret
.TIME_and_DATE_err:
    li a0, 1
    stack_push a0
    call FORTH$body$THROW
})
