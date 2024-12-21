define({line_comment_body}, {
  read_blk a0
  bnez a0, .line_comment_blk
  read_line_size a0
  REG_S_var a0, FORTH$body$PAO
  ret

.line_comment_blk:
  REG_L_var a0, FORTH$body$PAO
  and_acc_imm a0, -64
  add_acc_imm a0, 64
  REG_S_var a0, FORTH$body$PAO
  ret
})
