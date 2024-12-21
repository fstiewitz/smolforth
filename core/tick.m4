define({tick_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_fetch a0, 1
  lb a1, 0(a0)
  beqz a1, .tick_abort
  call FORTH$body$FIND
  stack_pop a1
  bnez a1, .tick_found
  /* is number */
  call FORTH$body$COUNT
  stack_fetch a1, 1
  stack_fetch a0, 2
  stack_rpush a0
  stack_rpush a1
  j unknown_word

.tick_found:
  stack_rpop_ra
  ret

.tick_abort:
  li a0, -16
  stack_push a0
  call FORTH$body$THROW
})
