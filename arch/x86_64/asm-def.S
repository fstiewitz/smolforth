#define WSHM 3
#define WORDSIZE 8
#define WORDSIZE_ALIGN_MASK 7
#define CELL .quad

#define W_IMMEDIATE 1
#define W_ADDR 2
#define W_CONSTANT 4
#define W_PUSH_MASK 14
#define W_EXEC 16
#define W_CREATE (W_ADDR+W_EXEC)
#define W_RUNTIME 32
#define W_DETACHED 64

#define x0 $0
#define a0 %rdi
#define a1 %rsi
# A2 must be set to RDX, because of (i)mul.
#define a2 %rdx
#define a3 %rcx
#define a4 %r8
#define a5 %r9

#define s0 %r15
#define s1 %rsp
#define s2 %r14

#define ra0 %rax
#define ra1 %rdx

#define bx0 $0
#define ba0 %dil
#define ba1 %sil
#define ba2 %dl
#define ba3 %cl

#define t0 %rax
#define bt0 %al

#define fa0 %xmm0
#define fa1 %xmm1
#define fa2 %xmm2
#define fa3 %xmm3
#define fa4 %xmm4
#define fa5 %xmm5
#define fa6 %xmm6
#define ft0 %xmm7

.macro REG_L dest, src
movq \src, \dest
.endm

.macro REG_S src, dest
movq \src, \dest
.endm

.macro REG_S_var src, dest
movq \src, \dest(%rip)
.endm

.macro REG_L_var dest, src
movq \src(%rip), \dest
.endm

.macro stack_fetch reg, num
movq -\num*WORDSIZE (%r15), \reg
.endm

.macro stack_store reg, num
movq \reg, -\num*WORDSIZE (%r15)
.endm

.macro stack_shrink num
addq $-\num*WORDSIZE, %r15
.endm

.macro stack_grow num
addq $\num*WORDSIZE, %r15
.endm

.macro stack_prepare
movq %rsp, %rbp
andq $-16, %rsp
.endm

.macro stack_restore
movq %rbp, %rsp
.endm

.macro stack_reset
  REG_L_var a0, sf_sys_RETURN_STACK_PTR
  add_acc_imm a0, -1*WORDSIZE
  mv s1, a0
.endm

.macro rstack_fetch reg, num
movq (\num-1)*WORDSIZE(%rsp), \reg
.endm

.macro rstack_store reg, num
movq \reg, (\num-1)*WORDSIZE(%rsp)
.endm

.macro rstack_shrink num
addq $\num*WORDSIZE , %rsp
.endm

.macro rstack_grow num
addq $-\num*WORDSIZE , %rsp
.endm

.macro stack_pop reg
addq $-WORDSIZE, %r15
movq (%r15), \reg
.endm

.macro stack_push reg
movq \reg, (%r15)
addq $WORDSIZE, %r15
.endm

.macro stack_rpop reg
movq 0(%rsp), \reg
addq $WORDSIZE, %rsp
.endm

.macro stack_rpush reg
addq $-WORDSIZE, %rsp
movq \reg, 0(%rsp)
.endm

.macro stack_rpush_ra
.endm

.macro stack_rpop_ra
.endm

.macro add_acc_imm reg, imm
addq $\imm, \reg
.endm

.macro and_acc_imm reg, imm
and $\imm, \reg
.endm

.macro add_acc reg, src
addq \src, \reg
.endm

.macro sub_acc reg, src
subq \src, \reg
.endm

.macro sub_to dest, src0, src1
movq \src0, \dest
sub \src1, \dest
.endm

.macro neg_acc reg
neg \reg
.endm

.macro and_to_imm dest, src, imm
movq $\imm, \dest
and \src, \dest
.endm

.macro and_acc dest, src
and \src, \dest
.endm

.macro or_acc_imm reg, imm
or $\imm, \reg
.endm

.macro or_acc reg, src
or \src, \reg
.endm

.macro xor_acc reg, src
xorq \src, \reg
.endm

.macro inv_acc reg
xorq $-1, \reg
.endm

.macro mul_to dest, src0, src1
movq \src0, \dest
imulq \src1, \dest
.endm

.macro div_to_clears_a2 dest, src0, src1
cmpq $0, \src0
movq $0, %rdx
setge %dl
sub $1, %rdx
movq \src0, %rax
idivq \src1
movq %rax, \dest
.endm

.macro rem_to_clears_a2 dest, src0, src1
cmpq $0, \src0
movq $0, %rdx
setge %dl
sub $1, %rdx
movq \src0, %rax
idivq \src1
movq %rdx, \dest
.endm

.macro mul2_to_a2 lower, src0, src1
movq \src1, %rax
imulq \src0
movq %rax, \lower
.endm

.macro mul2u_to_a2 lower, src0, src1
movq \src1, %rax
mulq \src0
movq %rax, \lower
.endm

.macro div2_to_a2 lower, src0, src1
cmpq $0, \src0
movq $0, %rdx
setge %dl
sub $1, %rdx
movq \src0, %rax
idivq \src1
movq %rax, \lower
.endm

.macro mul_acc dest, src
imulq \src, \dest
.endm

.macro mulhu_acc_a2 src
movq %rdx, %rax
mulq \src
.endm

.macro add_to dest, src0, src1
movq \src0, \dest
addq \src1, \dest
.endm

.macro add_to_imm dest, src, imm
movq $\imm, \dest
addq \src, \dest
.endm

.macro and_to dest, src0, src1
movq \src0, \dest
and \src1, \dest
.endm

.macro srl_to dest, src0, src1
movb \src1, %cl
movq \src0, \dest
shr %cl, \dest
.endm

.macro srl_acc_imm dest, imm
shr $\imm, \dest
.endm

.macro sra_acc_imm dest, imm
sar $\imm, \dest
.endm

.macro sll_to dest, src0, src1
movb \src1, %cl
movq \src0, \dest
shl %cl, \dest
.endm

.macro sll_acc_imm dest, imm
shl $\imm, \dest
.endm

.macro li reg, val
movq $\val, \reg
.endm

.macro la reg, addr
leaq \addr(%rip), \reg
.endm

.macro lb reg, addr
movsx \addr, \reg
.endm

.macro lbu reg, addr
movzx \addr, \reg
.endm

.macro lb_var reg, addr
movb \addr(%rip), \reg
.endm

.macro sb reg, addr
movb \reg, \addr
.endm

.macro mv dest, src
movq \src, \dest
.endm

.macro j dest
jmp \dest
.endm

.macro jr dest
jmp \dest
.endm


.macro bnez reg, target
cmp $0, \reg
jne \target
.endm

.macro beqz reg, target
cmp $0, \reg
je \target
.endm

.macro seqz r0, r1
cmp $0, \r1
sete \r0
.endm

.macro sltz r0, r1
cmp $0, \r1
setl \r0
.endm

.macro sgtz r0, r1
cmp $0, \r1
setg \r0
.endm

.macro snez r0, r1
cmp $0, \r1
setne \r0
.endm

.macro slt r0, r1, r2
cmp \r2, \r1
setl \r0
.endm

.macro set_clear r0
movq $0, \r0
.endm

.macro sltu br0, r1, r2
cmp \r2, \r1
setb \br0
.endm

.macro bltz reg, target
cmp $0, \reg
jl \target
.endm

.macro bgtz reg, target
cmp $0, \reg
jg \target
.endm

.macro bgez reg, target
cmp $0, \reg
jge \target
.endm

.macro blez reg, target
cmp $0, \reg
jle \target
.endm

.macro beq r0, r1, target
cmp \r0, \r1
je \target
.endm

.macro bne r0, r1, target
cmp \r0, \r1
jne \target
.endm

.macro bge r0, r1, target
cmp \r1, \r0
jge \target
.endm

.macro bgt r0, r1, target
cmp \r1, \r0
jg \target
.endm

.macro blt r0, r1, target
cmp \r1, \r0
jl \target
.endm

.macro bltu r0, r1, target
cmp \r1, \r0
jb \target
.endm

.macro defer_j jmp
leaq \jmp+2*WORDSIZE(%rip), %rax
stack_push %rax
movq \jmp+WORDSIZE(%rip), %rax
jmp *%rax
.endm

.macro defer_call jmp
leaq \jmp+2*WORDSIZE(%rip), %rax
stack_push %rax
movq \jmp+WORDSIZE(%rip), %rax
call *%rax
.endm

.macro read_blk reg
movq sf_sys_BLK(%rip), \reg
.endm

.macro read_state reg
movq sf_sys_STATE(%rip), \reg
.endm

.macro read_source_id reg
movq sf_sys_SOURCEID(%rip), \reg
.endm

.macro read_base reg
movq sf_sys_BASE(%rip), \reg
.endm

.macro read_here reg
movq sf_sys_ADATA(%rip), \reg
movq 2*WORDSIZE(\reg), \reg
.endm

.macro read_code_start reg
movq sf_sys_CODE_START(%rip), \reg
.endm

.macro read_code_gate reg
movq sf_sys_CODE_GATE(%rip), \reg
.endm

.macro read_code_END reg
movq sf_sys_CODE_END(%rip), \reg
.endm

.macro read_line_size reg
movq sf_sys_LINE_SIZE(%rip), \reg
.endm

.macro read_line_ptr reg
movq sf_sys_LINE_PTR(%rip), \reg
.endm

.macro write_blk reg
movq \reg, sf_sys_BLK(%rip)
.endm

.macro write_state reg
movq \reg, sf_sys_STATE(%rip)
.endm

.macro write_source_id reg
movq \reg, sf_sys_SOURCEID(%rip)
.endm

.macro write_base reg
movq \reg, sf_sys_BASE(%rip)
.endm

.macro write_here reg
movq sf_sys_ADATA(%rip), t0
movq \reg, 2*WORDSIZE(t0)
.endm

.macro write_line_size reg
movq \reg, sf_sys_LINE_SIZE(%rip)
.endm

.macro write_line_ptr reg
movq \reg, sf_sys_LINE_PTR(%rip)
.endm

.macro inc_csri
movq sf_sys_CSRI(%rip), t0
add_acc_imm t0, 1
movq t0, sf_sys_CSRI(%rip)
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
