/*
 * smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
 */
#if __riscv_xlen == 64
#define WORDSIZE 8
#define REG_L ld
#define REG_S sd
#elif __riscv_xlen == 32
#define WORDSIZE 4
#define REG_L lw
#define REG_S sw
#else
#error "smolforth requires RV32 or RV64"
#endif

.section .data

saved_registers:
    .space 13*WORDSIZE

.section .text

save_registers:
    la a5, saved_registers
    REG_S s0, 0*WORDSIZE(a5)
    REG_S s1, 1*WORDSIZE(a5)
    REG_S s2, 2*WORDSIZE(a5)
    REG_S s3, 3*WORDSIZE(a5)
    REG_S s4, 4*WORDSIZE(a5)
    REG_S s5, 5*WORDSIZE(a5)
    REG_S s6, 6*WORDSIZE(a5)
    REG_S s7, 7*WORDSIZE(a5)
    REG_S s8, 8*WORDSIZE(a5)
    REG_S s9, 9*WORDSIZE(a5)
    REG_S s10, 10*WORDSIZE(a5)
    REG_S s11, 11*WORDSIZE(a5)
    REG_S ra, 12*WORDSIZE(a5)
    jalr x0, 0(a7)


restore_registers:
    la a5, saved_registers
    REG_L s0, 0*WORDSIZE(a5)
    REG_L s1, 1*WORDSIZE(a5)
    REG_L s2, 2*WORDSIZE(a5)
    REG_L s3, 3*WORDSIZE(a5)
    REG_L s4, 4*WORDSIZE(a5)
    REG_L s5, 5*WORDSIZE(a5)
    REG_L s6, 6*WORDSIZE(a5)
    REG_L s7, 7*WORDSIZE(a5)
    REG_L s8, 8*WORDSIZE(a5)
    REG_L s9, 9*WORDSIZE(a5)
    REG_L s10, 10*WORDSIZE(a5)
    REG_L s11, 11*WORDSIZE(a5)
    REG_L ra, 12*WORDSIZE(a5)
    jalr x0, 0(a7)

.globl sf_to_c
sf_to_c:
    REG_S ra, 0(a1)
    addi a1, a1, WORDSIZE
    jalr a2
    addi a1, a1, -WORDSIZE
    REG_L ra, 0(a1)
    ret

.globl c_to_sf
c_to_sf:
    jal a7, save_registers
    jalr ra, a2
    jal a7, restore_registers
    ret

