define({COMPILE_FCONSTANT_raw_body}, {
CELL .defer_call
FORTH$body$COMPILE_FCONSTANT:
.globl FORTH$body$COMPILE_FCONSTANT
.set "FORTH$body$COMPILE-FCONSTANT", FORTH$body$COMPILE_FCONSTANT
.globl "FORTH$body$COMPILE-FCONSTANT"
CELL FORTH$SYS_COMPILE_FCONSTANT
})