define({RP_store_body}, {
    stack_rpop a1
    stack_pop a0
    mv s1, a0
    stack_rpush a1
    ret
})
