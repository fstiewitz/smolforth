define({to_NUMBER_body}, {
  stack_rpush_ra
  stack_pop a0 /* len */
  stack_pop a1 /* c-addr */
  stack_rpush a1
  stack_rpush a0
  stack_rpush x0
.to_NUMBER_ls: /* R: c-addr len i */
  rstack_fetch a1, 1 /* a1: i */
  rstack_fetch a0, 2 /* a2: len */
  beq a0, a1, .to_NUMBER_le
  rstack_fetch a2, 3
  add_acc a2, a1 /* a2: c + i */
  lb a2, 0(a2) /* a2: char */
  call .to_digit
  bltz a3, .to_NUMBER_le
  rstack_fetch a1, 1
  add_acc_imm a1, 1
  rstack_store a1, 1
  /* a3: digit */
  stack_pop a1 /* ud upper */
  stack_pop a0 /* ud lower */
  read_base a2

.toNNNN:
  mul_to a5, a2, a0 /* lower */
  mul_acc a1, a2 /* upper */
  add_acc a5, a3 /* lower + digit */
  set_clear a3
  sltu ba3, a5, a3 /* overflow-bit */
  mulhu_acc_a2 a0 /* upper of lower */
  add_acc a1, a2 /* add_to upper of lower to upper */
  add_acc a1, a3 /* add_to overflow-bit */
  stack_push a5
  stack_push a1
  j .to_NUMBER_ls
.to_NUMBER_le:
  stack_rpop a1 /* i */
  stack_rpop a0 /* len */
  stack_rpop a2 /* c-addr */
  sub_to a3, a0, a1
  add_acc a2, a1
  stack_push a2
  stack_push a3
  stack_rpop_ra
  ret

.to_digit:
  /* a2: character, a3: out, a0-a2 callee-saved */
  li a5, 0
  add_to_imm a3, a2, -0x30
  bltz a3, .to_digit_err
  li a4, 10
  blt a3, a4, .to_digit_end
  add_acc_imm a3, -0x11
  bltz a3, .to_digit_err
  li a5, 10
  li a4, 26
  blt a3, a4, .to_digit_end
  add_acc_imm a3, -0x20
  bltz a3, .to_digit_err
  blt a3, a4, .to_digit_end
  j .to_digit_err
.to_digit_end:
  add_acc a3, a5
  read_base a4
  bge a3, a4, .to_digit_err
  ret
.to_digit_err:
  li a3, -1
  ret
})
