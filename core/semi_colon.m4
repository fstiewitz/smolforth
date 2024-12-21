define({semi_colon_body}, {
  stack_rpush_ra
  call colon_exit
  mv a1, ra0
  beqz a1, .semi_colon_end
  stack_push a1
.semi_colon_end:
  stack_rpop_ra
  ret
})
