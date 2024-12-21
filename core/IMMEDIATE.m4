define({IMMEDIATE_body}, {
  la a0, wl_search_order
  li a1, -1
  add_acc_imm a1, M4WL_SO_MAX
  sll_acc_imm a1, WSHM
  add_acc a0, a1
  REG_L a0, (a0)
  REG_L a0, (a0)
  lbu a1, -1(a0)
  or_acc_imm a1, W_IMMEDIATE
  sb ba1, -1(a0)
  ret
})
