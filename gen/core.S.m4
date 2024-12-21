changequote(`{', `}')dnl
define(prev, {DIR_CELL 0})
define({cname}, {ifelse($2, {}, {$1}, {$2})})
define({define_word}, {
.balign M4WORDSIZE, 0
.ascii "\000patsubst({$1}, {\([\"]\)}, {\\\1})"
ifelse(eval((M4WORDSIZE-1)-((1+len({$1}))%M4WORDSIZE)), 0, {}, {dnl
.fill eval((M4WORDSIZE-1)-((1+len({$1}))%M4WORDSIZE)), 1, 1
})dnl
.byte $3
define({word_name}, cname({$1}, {$2}))
FORTH$word_name:
ifelse($2, {}, {}, {.set "FORTH$patsubst({$1}, {\([\"]\)}, {\\\1})", }FORTH$word_name)
ifelse($2, {}, {}, {.globl "FORTH$patsubst({$1}, {\([\"]\)}, {\\\1})"})
.globl FORTH$word_name
prev
define({prev}, {DIR_CELL }FORTH$word_name)
ifdef(cname({$1}, {$2}){_body}, {dnl
FORTH$body$word_name:
ifelse($2, {}, {}, {.set "FORTH$body$patsubst({$1}, {\([\"]\)}, {\\\1})", }FORTH$body$word_name)
ifelse($2, {}, {}, {.globl "FORTH$body$patsubst({$1}, {\([\"]\)}, {\\\1})"})
.globl FORTH$body$word_name
cname({$1}, {$2})_body}, {dnl
ifdef(cname({$1}, {$2}){_raw_body}, {dnl
cname({$1}, {$2})_raw_body}, {dnl
FORTH$body$word_name:
ifelse($2, {}, {}, {.set "FORTH$body$patsubst({$1}, {\([\"]\)}, {\\\1})", }FORTH$body$word_name)
ifelse($2, {}, {}, {.globl "FORTH$body$patsubst({$1}, {\([\"]\)}, {\\\1})"})
.globl FORTH$body$word_name
simple_tail(word_name{_impl})})})})dnl

.section .text, "wax", @progbits
#include<core/asm.S>

ifdef({SF_HAS_EMBEDDED}, {}, {
.balign WORDSIZE, 0
.ascii "\000FORTH\001"
.byte W_CREATE
FORTH:
.globl FORTH
CELL 0
CELL FORTH$body$WL_SET
body$FORTH:
.globl body$FORTH
CELL 0
CELL FORTH
define({prev}, {DIR_CELL }FORTH)
})
