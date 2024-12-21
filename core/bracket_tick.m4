define({bracket_tick_body}, {
  stack_rpush_ra
  call FORTH$body$BL
  call FORTH$body$WORD
  stack_fetch a0, 1
  lb a1, 0(a0)
  beqz a1, .tick_abort
  call FORTH$body$FIND
  stack_pop a1
  bnez a1, .bracket_tick_found
  /* is number */
  call FORTH$body$COUNT
  stack_fetch a1, 1
  stack_fetch a0, 2
  stack_rpush a0
  stack_rpush a1
  j unknown_word

.bracket_tick_found:
    stack_fetch a0, 1
    stack_store a0, 0
    stack_grow 1
    stack_rpop_ra
    defer_j FORTH$COMPILE_ADDR
})
