define({SOURCE_body}, {
  read_line_ptr a0
  read_line_size a1
  stack_store a0, 0
  stack_store a1, -1
  stack_grow 2
  ret
})
