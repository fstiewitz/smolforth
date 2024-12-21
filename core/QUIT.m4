define({QUIT_body}, {
  stack_rpush_ra
  stack_reset
  li a0, 0
  REG_S_var a0, sf_sys_ERRNO
  REG_S_var a0, sf_sys_HANDLER
  REG_S_var a0, sf_sys_STATE
.QUIT_ls:
  call FORTH$body$REFILL
  stack_pop a0
  beqz a0, .QUIT_abort
  read_line_size a2
  read_line_ptr a1
  // li a0, 1
  // call write
  call FORTH$body$SOURCE

  la a0, FORTH$EVALUATE_RAW
  stack_push a0
  call FORTH$body$CATCH
  stack_pop a0
  bnez a0, .QUIT_abort

  mv a0, x0
  j .QUIT_ls
.QUIT_ret:
  mv a0, x0
  stack_rpop_ra
  ret
.QUIT_abort:
  REG_L_var a1, FORTH$body$QUIT_CAUGHT
  beqz a1, .QUIT_abort_end
  stack_push a0
  defer_call FORTH$QUIT_CAUGHT
.QUIT_abort_end:
  li a0, 1
  stack_rpop_ra
  ret
})
