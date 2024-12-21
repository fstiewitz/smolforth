define({POSTPONE_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_fetch a0, 1
  lb a1, 0(a0)
  beqz a1, .POSTPONE_abort
  call FORTH$body$FIND
  stack_pop a1
  bnez a1, .postpone_found
  /* is number */
  call FORTH$body$COUNT
  stack_rpush a0
  stack_rpush a1
  j unknown_word

.postpone_found:
  stack_pop a0
  bgtz a1, .postpone_execute
  /* .postpone_compile: */
  stack_push a0
  stack_push a0
  defer_call FORTH$COMPILE_ADDR
  la a0, FORTH$COMPILE_comma
  stack_push a0
  call FORTH$body$COMPILE_comma
  stack_rpop_ra
  ret
.postpone_execute:
  stack_push a0
  stack_push a0
  defer_call FORTH$COMPILE_ADDR
  la a0, FORTH$EXECUTE
  stack_push a0
  call FORTH$body$COMPILE_comma
  stack_rpop_ra
  ret

.POSTPONE_abort:
  li a0, -48
  stack_push a0
  call FORTH$body$THROW
})
