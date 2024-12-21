define({colon_NONAME_body}, {
  stack_rpush_ra
  li a0, 0
  li a1, 0
  li a2, 0
  push_adata a3, sf_sys_CDATA
  stack_prepare
  call make_word
  call colon_enter
  stack_restore
  pop_adata a3
  stack_rpop_ra
  ret
})
