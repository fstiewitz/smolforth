define({WRITE_LINE_body}, {
  stack_rpush_ra
  stack_fetch a0, 1
  stack_fetch a1, 2
  stack_fetch a2, 3
  stack_grow 1
  stack_store a0, 1
  stack_store a1, 2
  stack_store a2, 3
  stack_store a0, 4
  call FORTH$body$WRITE_FILE
  stack_pop a0
  bnez a0, .WRITE_LINE_err
  la a0, .REFILL_char
  li a1, 13
  sb ba1, 0(a0)
  stack_fetch a1, 1
  stack_push a0
  li a2, 1
  stack_push a2
  stack_push a1
  call FORTH$body$WRITE_FILE
  stack_pop a0
  bnez a0, .WRITE_LINE_err
  la a0, .REFILL_char
  li a1, 10
  sb ba1, 0(a0)
  stack_pop a1
  stack_push a0
  li a2, 1
  stack_push a2
  stack_push a1
  call FORTH$body$WRITE_FILE
  stack_rpop_ra
  ret
.WRITE_LINE_err:
    stack_shrink 1
    stack_push a0
    stack_rpop_ra
    ret
})
