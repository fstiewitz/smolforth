define({COMPILE_ADDR_raw_body}, {
CELL .defer_call
FORTH$body$COMPILE_ADDR:
.globl FORTH$body$COMPILE_ADDR
.set "FORTH$body$COMPILE-ADDR", FORTH$body$COMPILE_ADDR
.globl "FORTH$body$COMPILE-ADDR"
CELL FORTH$SYS_COMPILE_ADDR
})
