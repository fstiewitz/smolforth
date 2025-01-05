#include <asm-def.S>

.section .bss

saved_registers:
    .space 7*WORDSIZE

.section .text

.globl sf_to_c
sf_to_c:
    sub $128, %rsp
    and $-32, %rsp
#ifdef SF_HAS_FLOAT
    REG_S_var s2, fps
#endif
    call *%rdx
    movq %rax, %r15
    movq %rdx, %rsp
#ifdef SF_HAS_FLOAT
    REG_L_var s2, fps
#endif
    ret

.globl c_to_sf
c_to_sf:
    pushq %rbp
    leaq saved_registers(%rip), %rax
    movq %rbx, 0*WORDSIZE(%rax)
    movq %rsp, 1*WORDSIZE(%rax)
    movq %rbp, 2*WORDSIZE(%rax)
    movq %r12, 3*WORDSIZE(%rax)
    movq %r13, 4*WORDSIZE(%rax)
    movq %r14, 5*WORDSIZE(%rax)
    movq %r15, 6*WORDSIZE(%rax)

#ifdef SF_HAS_FLOAT
    REG_L_var s2, fps
#endif
    movq %rdi, %r15
    movq %rsi, %rsp
    call *%rdx
    movq %r15, %rax
    movq %rsp, %rdx
#ifdef SF_HAS_FLOAT
    REG_S_var s2, fps
#endif

    leaq saved_registers(%rip), %rdi
    movq 0*WORDSIZE(%rdi), %rbx
    movq 1*WORDSIZE(%rdi), %rsp
    movq 2*WORDSIZE(%rdi), %rbp
    movq 3*WORDSIZE(%rdi), %r12
    movq 4*WORDSIZE(%rdi), %r13
    movq 5*WORDSIZE(%rdi), %r14
    movq 6*WORDSIZE(%rdi), %r15
    popq %rbp
    ret

