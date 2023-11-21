/*
 * smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
 */
#include "word.h"

.section .text
.globl core_current

#include "config.h"

#define SF_WORD_CORE 0

#ifdef SF_WORD_PLUS
.align 2
.ascii "+\000\000\000"
plus:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
add a2, a2, a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE plus
#endif

#ifdef SF_WORD_MINUS
.align 2
.ascii "-\000\000\000"
minus:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
sub a2, a3, a2
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE minus
#endif

#ifdef SF_WORD_CR
.align 2
.ascii "CR\000\000"
cr:
defword 4 SF_WORD_CORE 0
tail CR

#undef SF_WORD_CORE
#define SF_WORD_CORE cr
#endif

#ifdef SF_WORD_ONE_PLUS
.align 2
.ascii "1+\000\000"
plus1:
defword 4 SF_WORD_CORE 0
pop a2
addi a2, a2, 1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE plus1
#endif

#ifdef SF_WORD_ONE_MINUS
.align 2
.ascii "1-\000\000"
minus1:
defword 4 SF_WORD_CORE 0
pop a2
addi a2, a2, -1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE minus1
#endif

#ifdef SF_WORD_LINE_COMMENT
.align 2
.ascii "\\\000\000\000"
line_comment__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail line_comment

#undef SF_WORD_CORE
#define SF_WORD_CORE line_comment__
#endif

#ifdef SF_WORD_HEX
.align 2
.ascii "HEX\000"
hex__:
defword 4 SF_WORD_CORE 0
tail hex

#undef SF_WORD_CORE
#define SF_WORD_CORE hex__
#endif

#ifdef SF_WORD_DECIMAL
.align 2
.ascii "DECIMAL\000"
dec__:
defword 8 SF_WORD_CORE 0
tail decimal

#undef SF_WORD_CORE
#define SF_WORD_CORE dec__
#endif

#ifdef SF_WORD_VARIABLE
.align 2
.ascii "VARIABLE\000\000\000\000"
variable__:
defword 12 SF_WORD_CORE 0
tail variable

#undef SF_WORD_CORE
#define SF_WORD_CORE variable__
#endif

#ifdef SF_WORD_TRUE
.align 2
.ascii "TRUE\000\000\000\000"
true:
defword 8 SF_WORD_CORE 0
addi a2, x0, -1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE true
#endif

#ifdef SF_WORD_FALSE
.align 2
.ascii "FALSE\000\000\000"
false:
defword 8 SF_WORD_CORE 0
push x0
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE false
#endif

#ifdef SF_WORD_STORE
.align 2
.ascii "!\000\000\000"
store__:
defword 4 SF_WORD_CORE 0
#ifdef SF_SAFE_MEMORY
tail store
#else
pop a2
pop a3
REG_S a3, 0(a2)
ret
#endif

#undef SF_WORD_CORE
#define SF_WORD_CORE store__
#endif

#ifdef SF_WORD_FETCH
.align 2
.ascii "@\000\000\000"
fetch__:
defword 4 SF_WORD_CORE 0
#ifdef SF_SAFE_MEMORY
tail fetch
#else
pop a2
REG_L a2, 0(a2)
push a2
ret
#endif

#undef SF_WORD_CORE
#define SF_WORD_CORE fetch__
#endif

#ifdef SF_WORD_COMPILE_START
.align 2
.ascii ":\000\000\000"
compile__:
defword 4 SF_WORD_CORE 0
tail compile_start

#undef SF_WORD_CORE
#define SF_WORD_CORE compile__
#endif

#ifdef SF_WORD_COMPILE_END
.align 2
.ascii ";\000\000\000"
compile_end__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail compile_end

#undef SF_WORD_CORE
#define SF_WORD_CORE compile_end__
#endif

#ifdef SF_WORD_DEPTH
.align 2
.ascii "DEPTH\000\000\000"
depth__:
defword 8 SF_WORD_CORE 0
tail depth

#undef SF_WORD_CORE
#define SF_WORD_CORE depth__
#endif

#ifdef SF_WORD_QUESTION_DUP
.align 2
.ascii "?DUP\000\000\000\000"
qdup__:
defword 8 SF_WORD_CORE 0
REG_L a2, -WORDSIZE(a0)
beqz a2, dup__end
push a2
dup__end:
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE qdup__
#endif

#ifdef SF_WORD_DOT
.align 2
.ascii ".\000\000\000"
dot__:
defword 4 SF_WORD_CORE 0
tail dot

#undef SF_WORD_CORE
#define SF_WORD_CORE dot__
#endif

#ifdef SF_WORD_U_DOT
.align 2
.ascii "U.\000\000"
udot__:
defword 4 SF_WORD_CORE 0
tail udot

#undef SF_WORD_CORE
#define SF_WORD_CORE udot__
#endif

#ifdef SF_WORD_ACCEPT
.align 2
.ascii "ACCEPT\000\000"
accept__:
defword 8 SF_WORD_CORE 0
tail accept

#undef SF_WORD_CORE
#define SF_WORD_CORE accept__
#endif

#ifdef SF_WORD_IF
.align 2
.ascii "IF\000\000"
if__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail cs_if

#undef SF_WORD_CORE
#define SF_WORD_CORE if__
#endif

#ifdef SF_WORD_ELSE
.align 2
.ascii "ELSE\000\000\000\000"
else__:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_else

#undef SF_WORD_CORE
#define SF_WORD_CORE else__
#endif

#ifdef SF_WORD_THEN
.align 2
.ascii "THEN\000\000\000\000"
then__:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_then

#undef SF_WORD_CORE
#define SF_WORD_CORE then__
#endif

#ifdef SF_WORD_DUP
.align 2
.ascii "DUP\000"
dup__:
defword 4 SF_WORD_CORE 0
REG_L a2, -WORDSIZE(a0)
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE dup__
#endif

#ifdef SF_WORD_LESS_THAN_ZERO
.align 2
.ascii "0<\000\000"
lz:
defword 4 SF_WORD_CORE 0
pop a2
sltz a2, a2
sign_extend_push:
slli a2, a2, __riscv_xlen - 1
srai a2, a2, __riscv_xlen - 1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE lz
#endif

#ifdef SF_WORD_INVERT
.align 2
.ascii "INVERT\000\000"
invert:
defword 8 SF_WORD_CORE 0
invert_b:
pop a2
addi a3, x0, -1
xor a2, a2, a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE invert
#endif

#ifdef SF_WORD_NEGATE
.align 2
.ascii "NEGATE\000\000"
negate:
defword 8 SF_WORD_CORE 0
rpush ra
call invert_b
pop a2
addi a2, a2, 1
push a2
rpop ra
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE negate
#endif

#ifdef SF_WORD_DO
.align 2
.ascii "DO\000\000"
do:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail cs_do

#undef SF_WORD_CORE
#define SF_WORD_CORE do
#endif

#ifdef SF_WORD_PLUS_LOOP
.align 2
.ascii "+LOOP\000\000\000"
plus_loop:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_plus_loop

#undef SF_WORD_CORE
#define SF_WORD_CORE plus_loop
#endif

#ifdef SF_WORD_LOOP
.align 2
.ascii "LOOP\000\000\000\000"
loop:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_loop

#undef SF_WORD_CORE
#define SF_WORD_CORE loop
#endif

#ifdef SF_WORD_UNLOOP
.align 2
.ascii "UNLOOP\000\000"
unloop:
defword 8 SF_WORD_CORE 0
addi a1, a1, -2*WORDSIZE
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE unloop
#endif

#ifdef SF_WORD_I
.align 2
.ascii "I\000\000\000"
i:
defword 4 SF_WORD_CORE 0
REG_L a2, -2*WORDSIZE(a1)
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE i
#endif

#ifdef SF_WORD_J
.align 2
.ascii "J\000\000\000"
j:
defword 4 SF_WORD_CORE 0
REG_L a2, -4*WORDSIZE(a1)
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE j
#endif

#ifdef SF_WORD_BEGIN
.align 2
.ascii "BEGIN\000\000\000"
begin:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_begin

#undef SF_WORD_CORE
#define SF_WORD_CORE begin
#endif

#ifdef SF_WORD_UNTIL
.align 2
.ascii "UNTIL\000\000\000"
until:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_until

#undef SF_WORD_CORE
#define SF_WORD_CORE until
#endif

#ifdef SF_WORD_REPEAT
.align 2
.ascii "REPEAT\000\000"
repeat:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_repeat

#undef SF_WORD_CORE
#define SF_WORD_CORE repeat
#endif

#ifdef SF_WORD_WHILE
.align 2
.ascii "WHILE\000\000\000"
while:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail cs_while

#undef SF_WORD_CORE
#define SF_WORD_CORE while
#endif

#ifdef SF_WORD_DROP
.align 2
.ascii "DROP\000\000\000\000"
drop:
defword 8 SF_WORD_CORE 0
addi a0, a0, -WORDSIZE
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE drop
#endif

#ifdef SF_WORD_TYPE
.align 2
.ascii "TYPE\000\000\000\000"
type__:
defword 8 SF_WORD_CORE 0
tail type

#undef SF_WORD_CORE
#define SF_WORD_CORE type__
#endif

#ifdef SF_WORD_SOURCE
.align 2
.ascii "SOURCE\000\000"
source__:
defword 8 SF_WORD_CORE 0
tail source

#undef SF_WORD_CORE
#define SF_WORD_CORE source__
#endif

#ifdef SF_WORD_SYS_EXIT
.align 2
.ascii "sys:exit\000\000\000\000"
sys_exit__:
defword 12 SF_WORD_CORE 0
tail sys_exit

#undef SF_WORD_CORE
#define SF_WORD_CORE sys_exit__
#endif

#ifdef SF_WORD_CREATE
.align 2
.ascii "CREATE\000\000"
create__:
defword 8 SF_WORD_CORE 0
tail create

#undef SF_WORD_CORE
#define SF_WORD_CORE create__
#endif

#ifdef SF_WORD_CELLS
.align 2
.ascii "CELLS\000\000\000"
cells:
defword 8 SF_WORD_CORE 0
pop a2
slli a2, a2, WSHM
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE cells
#endif

#ifdef SF_WORD_ALLOT
.align 2
.ascii "ALLOT\000\000\000"
allot__:
defword 8 SF_WORD_CORE 0
tail allot

#undef SF_WORD_CORE
#define SF_WORD_CORE allot__
#endif

#ifdef SF_WORD_LESS_THAN
.align 2
.ascii "<\000\000\000"
lt:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
slt a2, a3, a2
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE lt
#endif

#ifdef SF_WORD_GREATER_THAN
.align 2
.ascii ">\000\000\000"
gt:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
slt a2, a2, a3
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE gt
#endif

#ifdef SF_WORD_U_LESS_THAN
.align 2
.ascii "U<\000\000"
ult:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
sltu a2, a3, a2
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE ult
#endif

#ifdef SF_WORD_EQ
.align 2
.ascii "=\000\000\000"
eq:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
sub a2, a2, a3
seqz a2, a2
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE eq
#endif

#ifdef SF_WORD_NEQ
.align 2
.ascii "<>\000\000"
neq:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
sub a2, a2, a3
snez a2, a2
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE neq
#endif

#ifdef SF_WORD_EQZ
.align 2
.ascii "0=\000\000"
eqz:
defword 4 SF_WORD_CORE 0
pop a2
seqz a2, a2
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE eqz
#endif

#ifdef SF_WORD_NEQZ
.align 2
.ascii "0<>\000"
neqz:
defword 4 SF_WORD_CORE 0
pop a2
snez a2, a2
j sign_extend_push

#undef SF_WORD_CORE
#define SF_WORD_CORE neqz
#endif

#ifdef SF_WORD_STRING_START
.align 2
.ascii "S\"\000\000"
s_start__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail s_start

#undef SF_WORD_CORE
#define SF_WORD_CORE s_start__
#endif

#ifdef SF_WORD_LEAVE
.align 2
.ascii "LEAVE\000\000\000"
leave__:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail leave

#undef SF_WORD_CORE
#define SF_WORD_CORE leave__
#endif

#ifdef SF_WORD_TO_R
.align 2
.ascii ">R\000\000"
to_r:
defword 4 SF_WORD_CORE 0
pop a2
rpush a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE to_r
#endif

#ifdef SF_WORD_FROM_R
.align 2
.ascii "R>\000\000"
from_r:
defword 4 SF_WORD_CORE 0
rpop a2
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE from_r
#endif

#ifdef SF_WORD_R_FETCH
.align 2
.ascii "R@\000\000"
fetch_r:
defword 4 SF_WORD_CORE 0
REG_L a2, -1*WORDSIZE(a1)
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE fetch_r
#endif

#ifdef SF_WORD_TO_IN
.align 2
.ascii ">IN\000"
to_in__:
defword 4 SF_WORD_CORE 0
tail to_in

#undef SF_WORD_CORE
#define SF_WORD_CORE to_in__
#endif

#ifdef SF_WORD_SDAD
.align 2
.ascii "SDAD\000\000\000\000"
sdad__:
defword 8 SF_WORD_CORE 0
tail sdad

#undef SF_WORD_CORE
#define SF_WORD_CORE sdad__
#endif

#ifdef SF_WORD_DBG_RSTACK
.align 2
.ascii "dbg-rstack\000\000"
dbg_rstack__:
defword 12 SF_WORD_CORE 0
tail dbg_rstack

#undef SF_WORD_CORE
#define SF_WORD_CORE dbg_rstack__
#endif

#ifdef SF_WORD_DBG_STACK
.align 2
.ascii "dbg-stack\000\000\000"
dbg_stack__:
defword 12 SF_WORD_CORE 0
tail dbg_stack

#undef SF_WORD_CORE
#define SF_WORD_CORE dbg_stack__
#endif

#ifdef SF_WORD_COMMENT
.align 2
.ascii "(\000\000\000"
comment__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail comment_start

#undef SF_WORD_CORE
#define SF_WORD_CORE comment__
#endif

#ifdef SF_WORD_AND
.align 2
.ascii "AND\000"
and:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
and a2, a2, a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE and
#endif

#ifdef SF_WORD_OR
.align 2
.ascii "OR\000\000"
or:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
or a2, a2, a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE or
#endif

#ifdef SF_WORD_XOR
.align 2
.ascii "XOR\000"
xor:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
xor a2, a2, a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE xor
#endif

#ifdef SF_WORD_CONSTANT
.align 2
.ascii "CONSTANT\000\000\000\000"
constant__:
defword 12 SF_WORD_CORE 0
tail constant

#undef SF_WORD_CORE
#define SF_WORD_CORE constant__
#endif

#ifdef SF_WORD_RSHIFT
.align 2
.ascii "RSHIFT\000\000"
rshift:
defword 8 SF_WORD_CORE 0
pop a2
pop a3
srl a2, a3, a2
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE rshift
#endif

#ifdef SF_WORD_LSHIFT
.align 2
.ascii "LSHIFT\000\000"
lshift:
defword 8 SF_WORD_CORE 0
pop a2
pop a3
sll a2, a3, a2
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE lshift
#endif

#ifdef SF_WORD_MUL_TWO
.align 2
.ascii "2*\000\000"
mul2:
defword 4 SF_WORD_CORE 0
pop a2
slli a2, a2, 1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE mul2
#endif

#ifdef SF_WORD_DIV_TWO
.align 2
.ascii "2/\000\000"
div2:
defword 4 SF_WORD_CORE 0
pop a2
srai a2, a2, 1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE div2
#endif

#ifdef SF_WORD_SWAP
.align 2
.ascii "SWAP\000\000\000\000"
swap:
defword 8 SF_WORD_CORE 0
pop a2
pop a3
push a2
push a3
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE swap
#endif

#ifdef SF_WORD_MIN
.align 2
.ascii "MIN\000"
min:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
blt a2, a3, pick2
push a3
ret
pick2:
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE min
#endif

#ifdef SF_WORD_MAX
.align 2
.ascii "MAX\000"
max:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
blt a3, a2, pick2
push a3
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE max
#endif

#ifdef SF_WORD_2DROP
.align 2
.ascii "2DROP\000\000\000"
drop2:
defword 8 SF_WORD_CORE 0
addi a0, a0, -2*WORDSIZE
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE drop2
#endif

#ifdef SF_WORD_2DUP
.align 2
.ascii "2DUP\000\000\000\000"
dup2:
defword 8 SF_WORD_CORE 0
REG_L a2, -1*WORDSIZE(a0)
REG_L a3, -2*WORDSIZE(a0)
push a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE dup2
#endif

#ifdef SF_WORD_NIP
.align 2
.ascii "NIP\000"
nip:
defword 4 SF_WORD_CORE 0
pop a2
addi a0, a0, -WORDSIZE
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE nip
#endif

#ifdef SF_WORD_2OVER
.align 2
.ascii "2OVER\000\000\000"
over2:
defword 8 SF_WORD_CORE 0
REG_L a2, -3*WORDSIZE(a0)
REG_L a3, -4*WORDSIZE(a0)
push a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE over2
#endif

#ifdef SF_WORD_2SWAP
.align 2
.ascii "2SWAP\000\000\000"
swap2:
defword 8 SF_WORD_CORE 0
pop a5
pop a4
pop a3
pop a2
push a4
push a5
push a2
push a3
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE swap2
#endif

#ifdef SF_WORD_OVER
.align 2
.ascii "OVER\000\000\000\000"
over:
defword 8 SF_WORD_CORE 0
REG_L a2, -2*WORDSIZE(a0)
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE over
#endif

#ifdef SF_WORD_ROT
.align 2
.ascii "ROT\000"
rot:
defword 4 SF_WORD_CORE 0
pop a4
pop a3
pop a2
push a3
push a4
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE rot
#endif

#ifdef SF_WORD_ABS
.align 2
.ascii "ABS\000"
abs:
defword 4 SF_WORD_CORE 0
pop a2
bltz a2, abs_inv
push a2
ret
abs_inv:
sub a2, x0, a2
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE abs
#endif

#ifdef SF_WORD_S_TO_D
.align 2
.ascii "S>D\000"
s_to_d:
defword 4 SF_WORD_CORE 0
REG_L a2, -1*WORDSIZE(a0)
bltz a2, stod_inv
push x0
ret
stod_inv:
addi a2, x0, -1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE s_to_d
#endif

#ifdef SF_WORD_MUL
.align 2
.ascii "*\000\000\000"
mul:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
mul a2, a2, a3
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE mul
#endif

#ifdef SF_WORD_M_MUL
.align 2
.ascii "M*\000\000"
m_star:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
mulh a4, a2, a3
mul a5, a2, a3
push a5
push a4
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE m_star
#endif

#ifdef SF_WORD_UM_MUL
.align 2
.ascii "UM*\000"
um_star:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
mulhu a4, a2, a3
mul a5, a2, a3
push a5
push a4
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE um_star
#endif

#ifdef SF_WORD_FM_MOD
.align 2
.ascii "FM/MOD\000\000"
fm_mod__:
defword 8 SF_WORD_CORE 0
tail fm_mod

#undef SF_WORD_CORE
#define SF_WORD_CORE fm_mod__
#endif

#ifdef SF_WORD_SM_REM
.align 2
.ascii "SM/REM\000\000"
sm_rem__:
defword 8 SF_WORD_CORE 0
tail sm_rem

#undef SF_WORD_CORE
#define SF_WORD_CORE sm_rem__
#endif

#ifdef SF_WORD_UM_MOD
.align 2
.ascii "UM/MOD\000\000"
um_mod__:
defword 8 SF_WORD_CORE 0
tail um_mod

#undef SF_WORD_CORE
#define SF_WORD_CORE um_mod__
#endif

#ifdef SF_WORD_INTERP_START
.align 2
.ascii "[\000\000\000"
interp_start__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail interp_start

#undef SF_WORD_CORE
#define SF_WORD_CORE interp_start__
#endif

#ifdef SF_WORD_INTERP_END
.align 2
.ascii "]\000\000\000"
interp_end__:
defword 4 SF_WORD_CORE 0
tail interp_end

#undef SF_WORD_CORE
#define SF_WORD_CORE interp_end__
#endif

#ifdef SF_WORD_DIV
.align 2
.ascii "/\000\000\000"
div:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
div a2, a3, a2
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE div
#endif

#ifdef SF_WORD_DIV_MOD
.align 2
.ascii "/MOD\000\000\000\000"
divmod:
defword 8 SF_WORD_CORE 0
pop a2
pop a3
div a4, a3, a2
rem a5, a3, a2
push a5
push a4
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE divmod
#endif

#ifdef SF_WORD_MOD
.align 2
.ascii "MOD\000"
mod:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
rem a5, a3, a2
push a5
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE mod
#endif

#ifdef SF_WORD_MUL_DIV_MOD
.align 2
.ascii "*/MOD\000\000\000"
muldivmod__:
defword 8 SF_WORD_CORE 0
tail muldivmod

#undef SF_WORD_CORE
#define SF_WORD_CORE muldivmod__
#endif

#ifdef SF_WORD_MUL_DIV
.align 2
.ascii "*/\000\000"
muldiv__:
defword 4 SF_WORD_CORE 0
tail muldiv

#undef SF_WORD_CORE
#define SF_WORD_CORE muldiv__
#endif

#ifdef SF_WORD_LITERAL
.align 2
.ascii "LITERAL\000"
literal__:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail literal

#undef SF_WORD_CORE
#define SF_WORD_CORE literal__
#endif

#ifdef SF_WORD_POSTPONE
.align 2
.ascii "POSTPONE\000\000\000\000"
postpone__:
defword 12 SF_WORD_CORE WORD_IMMEDIATE
tail postpone

#undef SF_WORD_CORE
#define SF_WORD_CORE postpone__
#endif

#ifdef SF_WORD_HERE
.align 2
.ascii "HERE\000\000\000\000"
here__:
defword 8 SF_WORD_CORE 0
tail here

#undef SF_WORD_CORE
#define SF_WORD_CORE here__
#endif

#ifdef SF_WORD_CELL_PLUS
.align 2
.ascii "CELL+\000\000\000"
cell_plus:
defword 8 SF_WORD_CORE 0
pop a2
addi a2, a2, WORDSIZE
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE cell_plus
#endif

#ifdef SF_WORD_CHAR_PLUS
.align 2
.ascii "CHAR+\000\000\000"
char_plus:
defword 8 SF_WORD_CORE 0
pop a2
addi a2, a2, 1
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE char_plus
#endif

#ifdef SF_WORD_C_COMMA
.align 2
.ascii "C,\000\000"
c_comma__:
defword 4 SF_WORD_CORE 0
tail c_comma

#undef SF_WORD_CORE
#define SF_WORD_CORE c_comma__
#endif

#ifdef SF_WORD_COMMA
.align 2
.ascii ",\000\000\000"
comma__:
defword 4 SF_WORD_CORE 0
tail comma

#undef SF_WORD_CORE
#define SF_WORD_CORE comma__
#endif

#ifdef SF_WORD_C_FETCH
.align 2
.ascii "C@\000\000"
c_fetch:
defword 4 SF_WORD_CORE 0
pop a2
lb a2, 0(a2)
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE c_fetch
#endif

#ifdef SF_WORD_C_STORE
.align 2
.ascii "C!\000\000"
c_store:
defword 4 SF_WORD_CORE 0
pop a2
pop a3
sb a3, 0(a2)
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE c_store
#endif

#ifdef SF_WORD_CHARS
.align 2
.ascii "CHARS\000\000\000"
chars:
defword 8 SF_WORD_CORE 0
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE chars
#endif

#ifdef SF_WORD_TWO_FETCH
.align 2
.ascii "2@\000\000"
fetch2__:
defword 4 SF_WORD_CORE 0
#ifdef SF_SAFE_MEMORY
tail fetch2
#else
pop a2
REG_L a3, 0(a2)
REG_L a4, WORDSIZE(a2)
push a4
push a3
ret
#endif

#undef SF_WORD_CORE
#define SF_WORD_CORE fetch2__
#endif

#ifdef SF_WORD_TWO_STORE
.align 2
.ascii "2!\000\000"
store2__:
defword 4 SF_WORD_CORE 0
#ifdef SF_SAFE_MEMORY
tail store2
#else
pop a2
pop a4
pop a3
REG_S a4, 0(a2)
REG_S a3, WORDSIZE(a2)
ret
#endif

#undef SF_WORD_CORE
#define SF_WORD_CORE store2__
#endif

#ifdef SF_WORD_ALIGN
.align 2
.ascii "ALIGN\000\000\000"
align__:
defword 8 SF_WORD_CORE 0
tail align

#undef SF_WORD_CORE
#define SF_WORD_CORE align__
#endif

#ifdef SF_WORD_ALIGNED
.align 2
.ascii "ALIGNED\000"
aligned:
defword 8 SF_WORD_CORE 0
pop a2
addi a3, x0, WORDSIZE
rem a4, a2, a3
beqz a4, is_aligned
sub a3, a3, a4
add a2, a2, a3
is_aligned:
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE aligned
#endif

#ifdef SF_WORD_PLUS_STORE
.align 2
.ascii "+!\000\000"
plus_store__:
defword 4 SF_WORD_CORE 0
#ifdef SF_SAFE_MEMORY
tail plus_store
#else
pop a2
pop a3
REG_L a4, 0(a2)
add a4, a4, a3
REG_S a4, 0(a2)
ret
#endif

#undef SF_WORD_CORE
#define SF_WORD_CORE plus_store__
#endif

#ifdef SF_WORD_BL
.align 2
.ascii "BL\000\000"
bl:
defword 4 SF_WORD_CORE 0
addi a2, x0, 32
push a2
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE bl
#endif

#ifdef SF_WORD_CHAR
.align 2
.ascii "CHAR\000\000\000\000"
char:
defword 8 SF_WORD_CORE 0
tail char_literal

#undef SF_WORD_CORE
#define SF_WORD_CORE char
#endif

#ifdef SF_WORD_CHAR_COMP
.align 2
.ascii "[CHAR]\000\000"
char_comp:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail char_literal_comp

#undef SF_WORD_CORE
#define SF_WORD_CORE char_comp
#endif

#ifdef SF_WORD_TICK
.align 2
.ascii "'\000\000\000"
tick__:
defword 4 SF_WORD_CORE 0
tail tick

#undef SF_WORD_CORE
#define SF_WORD_CORE tick__
#endif

#ifdef SF_WORD_TICK_COMP
.align 2
.ascii "[']\000"
bracket_tick__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail bracket_tick

#undef SF_WORD_CORE
#define SF_WORD_CORE bracket_tick__
#endif

#ifdef SF_WORD_FIND
.align 2
.ascii "FIND\000\000\000\000"
find__:
defword 8 SF_WORD_CORE 0
tail find

#undef SF_WORD_CORE
#define SF_WORD_CORE find__
#endif

#ifdef SF_WORD_EXECUTE
.align 2
.ascii "EXECUTE\000"
execute__:
defword 8 SF_WORD_CORE 0
tail execute

#undef SF_WORD_CORE
#define SF_WORD_CORE execute__
#endif

#ifdef SF_WORD_IMMEDIATE
.align 2
.ascii "IMMEDIATE\000\000\000"
immediate__:
defword 12 SF_WORD_CORE WORD_IMMEDIATE
tail immediate

#undef SF_WORD_CORE
#define SF_WORD_CORE immediate__
#endif

#ifdef SF_WORD_COUNT
.align 2
.ascii "COUNT\000\000\000"
count__:
defword 8 SF_WORD_CORE 0
tail count

#undef SF_WORD_CORE
#define SF_WORD_CORE count__
#endif

#ifdef SF_WORD_STATE
.align 2
.ascii "STATE\000\000\000"
state__:
defword 8 SF_WORD_CORE 0
tail state

#undef SF_WORD_CORE
#define SF_WORD_CORE state__
#endif

#ifdef SF_WORD_RECURSE
.align 2
.ascii "RECURSE\000"
recurse__:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail recurse

#undef SF_WORD_CORE
#define SF_WORD_CORE recurse__
#endif

#ifdef SF_WORD_EXIT
.align 2
.ascii "EXIT\000\000\000\000"
exit:
defword 8 SF_WORD_CORE 0
rpop a2
jr a2

#undef SF_WORD_CORE
#define SF_WORD_CORE exit
#endif

#ifdef SF_WORD_TO_BODY
.align 2
.ascii ">BODY\000\000\000"
body__:
defword 8 SF_WORD_CORE 0
tail body

#undef SF_WORD_CORE
#define SF_WORD_CORE body__
#endif

#ifdef SF_WORD_TO_DOES
.align 2
.ascii "DOES>\000\000\000"
does__:
defword 8 SF_WORD_CORE WORD_IMMEDIATE
tail does

#undef SF_WORD_CORE
#define SF_WORD_CORE does__
#endif

#ifdef SF_WORD_EVALUATE
.align 2
.ascii "EVALUATE\000\000\000\000"
evaluate__:
defword 12 SF_WORD_CORE 0
tail evaluate

#undef SF_WORD_CORE
#define SF_WORD_CORE evaluate__
#endif

#ifdef SF_WORD_WORD
.align 2
.ascii "WORD\000\000\000\000"
word__:
defword 8 SF_WORD_CORE 0
tail word

#undef SF_WORD_CORE
#define SF_WORD_CORE word__
#endif

#ifdef SF_WORD_PO_START
.align 2
.ascii "<#\000\000"
po_start__:
defword 4 SF_WORD_CORE 0
tail po_start

#undef SF_WORD_CORE
#define SF_WORD_CORE po_start__
#endif

#ifdef SF_WORD_PO_NUMBER
.align 2
.ascii "#\000\000\000"
number_sign__:
defword 4 SF_WORD_CORE 0
tail number_sign

#undef SF_WORD_CORE
#define SF_WORD_CORE number_sign__
#endif

#ifdef SF_WORD_PO_NUMBER_S
.align 2
.ascii "#S\000\000"
number_sign_s__:
defword 4 SF_WORD_CORE 0
tail number_sign_s

#undef SF_WORD_CORE
#define SF_WORD_CORE number_sign_s__
#endif

#ifdef SF_WORD_PO_END
.align 2
.ascii "#>\000\000"
po_end__:
defword 4 SF_WORD_CORE 0
tail po_end

#undef SF_WORD_CORE
#define SF_WORD_CORE po_end__
#endif

#ifdef SF_WORD_HOLD
.align 2
.ascii "HOLD\000\000\000\000"
hold__:
defword 8 SF_WORD_CORE 0
tail hold

#undef SF_WORD_CORE
#define SF_WORD_CORE hold__
#endif

#ifdef SF_WORD_SIGN
.align 2
.ascii "SIGN\000\000\000\000"
sign__:
defword 8 SF_WORD_CORE 0
tail sign

#undef SF_WORD_CORE
#define SF_WORD_CORE sign__
#endif

#ifdef SF_WORD_TO_NUMBER
.align 2
.ascii ">NUMBER\000"
to_number__:
defword 8 SF_WORD_CORE 0
tail to_number

#undef SF_WORD_CORE
#define SF_WORD_CORE to_number__
#endif

#ifdef SF_WORD_BASE
.align 2
.ascii "BASE\000\000\000\000"
base__:
defword 8 SF_WORD_CORE 0
tail base

#undef SF_WORD_CORE
#define SF_WORD_CORE base__
#endif

#ifdef SF_WORD_DOT_STRING
.align 2
.ascii ".\"\000\000"
dot_string__:
defword 4 SF_WORD_CORE WORD_IMMEDIATE
tail dot_string

#undef SF_WORD_CORE
#define SF_WORD_CORE dot_string__
#endif

#ifdef SF_WORD_EMIT
.align 2
.ascii "EMIT\000\000\000\000"
emit__:
defword 8 SF_WORD_CORE 0
tail emit

#undef SF_WORD_CORE
#define SF_WORD_CORE emit__
#endif

#ifdef SF_WORD_SPACE
.align 2
.ascii "SPACE\000\000\000"
space:
defword 8 SF_WORD_CORE 0
li a2, 32
push a2
tail emit

#undef SF_WORD_CORE
#define SF_WORD_CORE space
#endif

#ifdef SF_WORD_SPACES
.align 2
.ascii "SPACES\000\000"
spaces:
defword 8 SF_WORD_CORE 0
rpush ra
pop a3
spaces_t:
addi a3, a3, -1
bltz a3, spaces_end
rpush a3
li a2, 32
push a2
call emit
rpop a3
j spaces_t
spaces_end:
rpop ra
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE spaces
#endif

#ifdef SF_WORD_MOVE
.align 2
.ascii "MOVE\000\000\000\000"
move:
defword 8 SF_WORD_CORE 0
move_p:
pop a4 /* len */
pop a3 /* dest */
pop a2 /* source */
beq a2, a3, move_same
beqz a4, move_same
blt a3, a2, move_forward
add a2, a2, a4
add a3, a3, a4
addi a2, a2, -1
addi a3, a3, -1
move_backward:
lbu a5, 0(a2)
sb a5, 0(a3)
addi a2, a2, -1
addi a3, a3, -1
addi a4, a4, -1
bnez a4, move_backward
ret
move_forward:
lbu a5, 0(a2)
sb a5, 0(a3)
addi a2, a2, 1
addi a3, a3, 1
addi a4, a4, -1
bnez a4, move_forward
ret
move_same:
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE move
#endif

#ifdef SF_WORD_FILL
.align 2
.ascii "FILL\000\000\000\000"
fill:
defword 8 SF_WORD_CORE 0
pop a4
pop a3
pop a2
beqz a3, move_same
fill_r:
sb a4, 0(a2)
addi a2, a2, 1
addi a3, a3, -1
bnez a3, fill_r
ret

#undef SF_WORD_CORE
#define SF_WORD_CORE fill
#endif

.set core_current, SF_WORD_CORE
