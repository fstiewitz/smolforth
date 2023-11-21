/*
* smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
*/
#pragma once
#if __riscv_xlen == 64
#define WORDSIZE 8
#define REG_L ld
#define REG_S sd
#define WSHM 3
#define CELL .dword
#elif __riscv_xlen == 32
#define WORDSIZE 4
#define REG_L lw
#define REG_S sw
#define WSHM 2
#define CELL .word
#else
#error "smolforth requires RV32 or RV64"
#endif

#define WORD_IMMEDIATE 1
#define WORD_DID 2
#define WORD_ADDR 4

.macro pop reg
addi a0, a0, -WORDSIZE
REG_L \reg, 0(a0)
.endm

.macro push reg
REG_S \reg, 0(a0)
addi a0, a0, WORDSIZE
.endm

.macro rpop reg
addi a1, a1, -WORDSIZE
REG_L \reg, 0(a1)
.endm

.macro rpush reg
REG_S \reg, 0(a1)
addi a1, a1, WORDSIZE
.endm

.macro defword off, link, flags
CELL \off
CELL \link
CELL \flags
.endm
