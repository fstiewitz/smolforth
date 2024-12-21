#include <asm-def.S>

.section .bss
.balign WORDSIZE, 0
sf_sys_STATE:
sf_header:
.globl sf_header
CELL 0
sf_sys_ERRNO:
CELL 0
sf_sys_ERR_STR:
CELL 0
sf_sys_ERR_SIZE:
CELL 0
sf_sys_COMPILER_STATUS:
CELL 0
sf_sys_SOURCEID:
CELL 0
sf_sys_BLK:
CELL 0
sf_sys_BASE:
CELL 0
sf_sys_CODE_START:
CELL 0
sf_sys_CODE_GATE:
CELL 0
CELL 0
sf_sys_CODE_END:
CELL 0
CELL 0
CELL 0
sf_sys_ADATA:
CELL 0
sf_sys_CDATA:
CELL 0
sf_sys_IDATA:
CELL 0
sf_sys_UDATA:
CELL 0
sf_sys_WDATA:
CELL 0
sf_sys_UIDATA:
CELL 0
sf_sys_ICDATA:
CELL 0
sf_sys_LINE_PTR:
CELL 0
sf_sys_LINE_SIZE:
CELL 0
sf_sys_HANDLER:
CELL 0
sf_sys_STACK_PTR:
CELL 0
sf_sys_STACK_SIZE:
CELL 0
sf_sys_RETURN_STACK_PTR:
CELL 0
sf_sys_RETURN_STACK_SIZE:
CELL 0
sf_sys_CSRI:
CELL 0
sf_sys_PO:
.fill 256, 1, 0

.section .text
