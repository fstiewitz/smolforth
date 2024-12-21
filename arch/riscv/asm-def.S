#if __riscv_xlen == 64
#define WORDSIZE 8
#define WORDSIZE_ALIGN_MASK 7
#define WSHM 3
#define FWSHM 3
#define REG_L ld
#define REG_S sd
#define FREG_L fld
#define FREG_S fsd
#define FWORDSIZE 8
#define CELL .dword
#elif __riscv_xlen == 32
#define WORDSIZE 4
#define WORDSIZE_ALIGN_MASK 3
#define WSHM 2
#define FWSHM 2
#define REG_L lw
#define REG_S sw
#define FREG_L flw
#define FREG_S fsw
#define FWORDSIZE 4
#define CELL .word
#else
#error "smolforth requires RV32 or RV64"
#endif

#define W_IMMEDIATE 1
#define W_ADDR 2
#define W_CONSTANT 4
#define W_PUSH_MASK 14
#define W_EXEC 16
#define W_CREATE (W_ADDR+W_EXEC)
#define W_RUNTIME 32
#define W_DETACHED 64

#define ra0 a0
#define ra1 a1

#define bx0 x0
#define ba0 a0
#define ba1 a1
#define ba2 a2
#define ba3 a3

.macro REG_S_var src, dest
REG_S \src, \dest, t6
.endm

.macro REG_L_var dest, src
REG_L \dest, \src
.endm

.macro stack_fetch reg, num
REG_L \reg, -\num*WORDSIZE (s0)
.endm

.macro stack_store reg, num
REG_S \reg, -\num*WORDSIZE (s0)
.endm

.macro stack_shrink num
addi s0, s0, -\num*WORDSIZE
.endm

.macro stack_grow num
addi s0, s0, \num*WORDSIZE
.endm

.macro stack_prepare
.endm

.macro stack_restore
.endm

.macro stack_reset
  REG_L_var a0, sf_sys_RETURN_STACK_PTR
  add_acc_imm a0, 1*WORDSIZE
  mv s1, a0
.endm

.macro rstack_fetch reg, num
REG_L \reg, -\num*WORDSIZE (s1)
.endm

.macro rstack_store reg, num
REG_S \reg, -\num*WORDSIZE (s1)
.endm

.macro rstack_shrink num
addi s1, s1, -\num*WORDSIZE
.endm

.macro rstack_grow num
addi s1, s1, \num*WORDSIZE
.endm

.macro stack_pop reg
addi s0, s0, -WORDSIZE
REG_L \reg, 0(s0)
.endm

.macro stack_push reg
REG_S \reg, 0(s0)
addi s0, s0, WORDSIZE
.endm

.macro stack_rpop reg
addi s1, s1, -WORDSIZE
REG_L \reg, 0(s1)
.endm

.macro stack_rpush reg
REG_S \reg, 0(s1)
addi s1, s1, WORDSIZE
.endm

.macro stack_rpush_ra
stack_rpush ra
.endm

.macro stack_rpop_ra
stack_rpop ra
.endm

.macro add_acc_imm reg, imm
addi \reg, \reg, \imm
.endm

.macro and_acc_imm reg, imm
andi \reg, \reg, \imm
.endm

.macro or_acc_imm reg, imm
ori \reg, \reg, \imm
.endm

.macro add_acc reg, src
add \reg, \reg, \src
.endm

.macro sub_acc reg, src
sub \reg, \reg, \src
.endm

.macro sub_to d, s0, s1
sub \d, \s0, \s1
.endm

.macro neg_acc reg
sub \reg, x0, \reg
.endm

.macro add_to d, s0, s1
add \d, \s0, \s1
.endm

.macro and_to_imm d, s0, s1
andi \d, \s0, \s1
.endm

.macro and_acc reg, src
and \reg, \reg, \src
.endm

.macro or_acc reg, src
or \reg, \reg, \src
.endm

.macro xor_acc reg, src
xor \reg, \reg, \src
.endm

.macro inv_acc reg
not \reg, \reg
.endm

.macro and_to d, s0, s1
and \d, \s0, \s1
.endm

.macro set_clear r0
.endm

.macro mul_to dest, src0, src1
mul \dest, \src0, \src1
.endm

.macro div_to_clears_a2 dest, src0, src1
div \dest, \src0, \src1
.endm

.macro rem_to_clears_a2 dest, src0, src1
rem \dest, \src0, \src1
.endm

.macro mul2_to_a2 lower, src0, src1
mulh a2, \src0, \src1
mul \lower, \src0, \src1
.endm

.macro mul2u_to_a2 lower, src0, src1
mulhu a2, \src0, \src1
mul \lower, \src0, \src1
.endm

.macro div2_to_a2 lower, src0, src1
div \lower, \src0, \src1
rem a2, \src0, \src1
.endm

.macro mul_acc dest, src
mul \dest, \dest, \src
.endm

.macro mulhu_acc_a2 src
mulhu a2, a2, \src
.endm

.macro add_to_imm dest, src, imm
addi \dest, \src, \imm
.endm

.macro srl_to dest, src0, src1
srl \dest, \src0, \src1
.endm

.macro srl_acc_imm dest, imm
srli \dest, \dest, \imm
.endm

.macro sra_acc_imm dest, imm
sra \dest, \dest, \imm
.endm

.macro sll_to dest, src0, src1
sll \dest, \src0, \src1
.endm

.macro sll_acc_imm dest, imm
slli \dest, \dest, \imm
.endm

.macro lb_var reg, addr
lb \reg, \addr
.endm

.macro defer_j jmp
la x6, \jmp+2*WORDSIZE
stack_push x6
REG_L x6, \jmp+WORDSIZE
jr x6
.endm

.macro defer_call jmp
la ra, \jmp+2*WORDSIZE
stack_push ra
REG_L ra, \jmp+WORDSIZE
jalr ra, 0(ra)
.endm


.macro read_blk reg
REG_L \reg, sf_sys_BLK
.endm

.macro read_state reg
REG_L \reg, sf_sys_STATE
.endm

.macro read_source_id reg
REG_L \reg, sf_sys_SOURCEID
.endm

.macro read_base reg
REG_L \reg, sf_sys_BASE
.endm

.macro read_here reg
REG_L \reg, sf_sys_ADATA
REG_L \reg, 2*WORDSIZE(\reg)
.endm

.macro read_code_start reg
REG_L \reg, sf_sys_CODE_START
.endm

.macro read_code_gate reg
REG_L \reg, sf_sys_CODE_GATE
.endm

.macro read_code_end reg
REG_L \reg, sf_sys_CODE_END
.endm

.macro read_line_size reg
REG_L \reg, sf_sys_LINE_SIZE
.endm

.macro read_line_ptr reg
REG_L \reg, sf_sys_LINE_PTR
.endm

.macro write_blk reg
REG_S \reg, sf_sys_BLK, t6
.endm

.macro write_state reg
REG_S \reg, sf_sys_STATE, t6
.endm

.macro write_source_id reg
REG_S \reg, sf_sys_SOURCEID, t6
.endm

.macro write_base reg
REG_S \reg, sf_sys_BASE, t6
.endm

.macro write_here reg
REG_L t6, sf_sys_ADATA
REG_S \reg, 2*WORDSIZE(t6)
.endm

.macro write_line_size reg
REG_S \reg, sf_sys_LINE_SIZE, t6
.endm

.macro write_line_ptr reg
REG_S \reg, sf_sys_LINE_PTR, t6
.endm

.macro inc_csri
REG_L t5, sf_sys_CSRI, t6
addi t5, t5, 1
REG_S t5, sf_sys_CSRI, t6
.endm

.macro push_adata reg, data
  REG_L_var \reg, sf_sys_ADATA
  stack_rpush \reg
  REG_L_var \reg, \data
  REG_S_var \reg, sf_sys_ADATA
.endm

.macro pop_adata reg
  stack_rpop \reg
  REG_S_var \reg, sf_sys_ADATA
.endm

#include <asm-F.S>
