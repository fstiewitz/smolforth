/*
 * smolforth (c) 2023 by Fabian Stiewitz is licensed under Attribution-ShareAlike 4.0 International.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
 */
#pragma once

#include <assert.h>
#include <stdio.h>
#include <stdint.h>

#define ASMGEN_RISCV_32I
#define ASMGEN_RISCV_64I
#define ASMGEN_RISCV_32M
#define ASMGEN_RISCV_64M
#define ASMGEN_RISCV_32A
#define ASMGEN_RISCV_64A
#define ASMGEN_RISCV_ZICSR

#define X0 0
#define X1 1
#define X2 2
#define X3 3
#define X4 4
#define X5 5
#define X6 6
#define X7 7
#define X8 8
#define X9 9
#define X10 10
#define X11 11
#define X12 12
#define X13 13
#define X14 14
#define X15 15
#define X16 16
#define X17 17
#define X18 18
#define X19 19
#define X20 20
#define X21 21
#define X22 22
#define X23 23
#define X24 24
#define X25 25
#define X26 26
#define X27 27
#define X28 28
#define X29 29
#define X30 30
#define X31 31

#define ZERO 0
#define RA X1
#define SP X2
#define GP X3
#define TP X4
#define T0 X5
#define T1 X6
#define T2 X7
#define S0 X8
#define FP X8
#define S1 X9
#define A0 X10
#define A1 X11
#define A2 X12
#define A3 X13
#define A4 X14
#define A5 X15
#define A6 X16
#define A7 X17
#define S2 X18
#define S3 X19
#define S4 X20
#define S5 X21
#define S6 X22
#define S7 X23
#define S8 X24
#define S9 X25
#define S10 X26
#define S11 X27
#define T3 X28
#define T4 X29
#define T5 X30
#define T6 X31

struct r_type {
	unsigned int opcode : 7;
	unsigned int rd : 5;
	unsigned int funct3 : 3;
	unsigned int rs1 : 5;
	unsigned int rs2 : 5;
	unsigned int funct7 : 7;
};

#define RINSTR(Name, Op, Func1, Func2)                                                   \
	inline static void asmgen_##Name(unsigned rd, unsigned rs1, unsigned rs2, char **p) { \
		struct r_type t = { .opcode = Op,                                                \
			                .rd = (unsigned) rd,                                         \
			                .funct3 = Func1,                                             \
			                .rs1 = (unsigned) rs1,                                       \
			                .rs2 = (unsigned) rs2,                                       \
			                .funct7 = Func2 };                                           \
		*((struct r_type *) *p) = t;                                                     \
		*p += sizeof(struct r_type);                                                     \
	}

#define SRINSTR(Name, Op, Func1, Func2)                                                  \
	inline static void asmgen_##Name(int rd, int rs1, int rs2, char **p) { \
		struct r_type t = { .opcode = Op,                                                \
			                .rd = (unsigned) rd,                                         \
			                .funct3 = Func1,                                             \
			                .rs1 = (unsigned) rs1,                                       \
			                .rs2 = (unsigned) rs2,                                       \
			                .funct7 = (unsigned) Func2 | ((rs2 >> 5) & 1) };                        \
		*((struct r_type *) *p) = t;                                                     \
		*p += sizeof(struct r_type);                                                     \
	}

struct i_type {
	unsigned int opcode : 7;
	unsigned int rd : 5;
	unsigned int funct3 : 3;
	unsigned int rs1 : 5;
	unsigned int imm : 12;
};

inline static void
i_type_imm(struct i_type *t, intptr_t imm) {
	t->imm = imm & 0xfff;
}

#define IINSTR(Name, Op, Func)                                                                          \
	inline static void asmgen_##Name(unsigned rd, unsigned rs1, intptr_t imm, char **p) {                         \
		struct i_type t = { .opcode = Op, .rd = (unsigned) rd, .funct3 = Func, .rs1 = (unsigned) rs1 }; \
		i_type_imm(&t, imm);                                                                            \
		*((struct i_type *) *p) = t;                                                                    \
		*p += sizeof(struct i_type);                                                                    \
	}

struct s_type {
	unsigned int opcode : 7;
	unsigned int imm0 : 5;
	unsigned int funct3 : 3;
	unsigned int rs1 : 5;
	unsigned int rs2 : 5;
	unsigned int imm1 : 7;
};

inline static void
s_type_imm(struct s_type *t, uint32_t imm) {
	t->imm0 = imm & 0x1f;
	t->imm1 = (imm >> 5) & 0x3f;
	t->imm1 |= (imm >> 31) << 6;
}

#define SINSTR(Name, Op, Func)                                                                            \
	inline static void asmgen_##Name(int rs2, int rs1, uint32_t imm, char **p) {                          \
		struct s_type t = { .opcode = Op, .funct3 = Func, .rs1 = (unsigned) rs1, .rs2 = (unsigned) rs2 }; \
		s_type_imm(&t, imm);                                                                              \
		*((struct s_type *) *p) = t;                                                                      \
		*p += sizeof(struct s_type);                                                                      \
	}

struct b_type {
	unsigned int opcode : 7;
	unsigned int imm0 : 1;
	unsigned int imm1 : 4;
	unsigned int funct3 : 3;
	unsigned int rs1 : 5;
	unsigned int rs2 : 5;
	unsigned int imm2 : 6;
	unsigned int imm3 : 1;
};

inline static void
b_type_imm(struct b_type *t, uint32_t imm) {
	t->imm0 = (imm >> 11) & 1;
	t->imm1 = (imm >> 1) & 0xf;
	t->imm2 = (imm >> 5) & 0x3f;
	t->imm3 = (imm >> 31) & 1;
}

#define BINSTR(Name, Op, Func)                                                                            \
	inline static void asmgen_##Name(int rs1, int rs2, uint32_t imm, char **p) {                          \
		struct b_type t = { .opcode = Op, .funct3 = Func, .rs1 = (unsigned) rs1, .rs2 = (unsigned) rs2 }; \
		assert(!(imm & 1));                                                                               \
		b_type_imm(&t, imm);                                                                              \
		*((struct b_type *) *p) = t;                                                                      \
		*p += sizeof(struct b_type);                                                                      \
	}

struct u_type {
	unsigned int opcode : 7;
	unsigned int rd : 5;
	unsigned int imm : 20;
};

inline static void
u_type_imm(struct u_type *t, uint32_t imm) {
	t->imm = imm;
}

#define UINSTR(Name, Op)                                                        \
	inline static void asmgen_##Name(unsigned int rd, uint32_t imm, char **p) { \
		struct u_type t = { .opcode = Op, .rd = rd };                           \
		u_type_imm(&t, imm);                                                    \
		*((struct u_type *) *p) = t;                                            \
		*p += sizeof(struct u_type);                                            \
	}

struct j_type {
	unsigned int opcode : 7;
	unsigned int rd : 5;
	unsigned int imm0 : 8;
	unsigned int imm1 : 1;
	unsigned int imm2 : 10;
	unsigned int imm3 : 1;
};

inline static void
j_type_imm(struct j_type *t, uint32_t imm) {
	t->imm0 = (imm >> 12) & 0xff;
	t->imm1 = (imm >> 11) & 1;
	t->imm2 = (imm >> 1) & 0x3ff;
	t->imm3 = (imm >> 20) & 1;
}

#define JINSTR(Name, Op)                                                        \
	inline static void asmgen_##Name(unsigned int rd, uint32_t imm, char **p) { \
		struct j_type t = { .opcode = Op, .rd = rd };                           \
		j_type_imm(&t, imm);                                                    \
		*((struct j_type *) *p) = t;                                            \
		*p += sizeof(struct j_type);                                            \
	}

#if (defined ASMGEN_RISCV_32I) || (defined ASMGEN_RISCV_64I)

#define OP_LUI 0b0110111
#define OP_AUIPC 0b0010111
#define OP_JAL 0b1101111
#define OP_JALR 0b1100111
#define OP_BEQ 0b1100011
#define OP_BNE 0b1100011
#define OP_BLT 0b1100011
#define OP_BGE 0b1100011
#define OP_BLTU 0b1100011
#define OP_BGEU 0b1100011
#define OP_LB 0b0000011
#define OP_LH 0b0000011
#define OP_LW 0b0000011
#define OP_LBU 0b0000011
#define OP_LHU 0b0000011
#define OP_SB 0b0100011
#define OP_SH 0b0100011
#define OP_SW 0b0100011
#define OP_ADDI 0b0010011
#define OP_SLTI 0b0010011
#define OP_SLTIU 0b0010011
#define OP_XORI 0b0010011
#define OP_ORI 0b0010011
#define OP_ANDI 0b0010011

#define OP_SLLI 0b0010011
#define OP_SRLI 0b0010011
#define OP_SRAI 0b0010011
#define OP_ADD 0b0110011
#define OP_SUB 0b0110011
#define OP_SLL 0b0110011
#define OP_SLT 0b0110011
#define OP_SLTU 0b0110011
#define OP_XOR 0b0110011
#define OP_SRL 0b0110011
#define OP_SRA 0b0110011
#define OP_OR 0b0110011
#define OP_AND 0b0110011

#define FUNC_JALR 0b000
#define FUNC_BEQ 0b000
#define FUNC_BNE 0b001
#define FUNC_BLT 0b100
#define FUNC_BGE 0b101
#define FUNC_BLTU 0b110
#define FUNC_BGEU 0b111
#define FUNC_LB 0b000
#define FUNC_LH 0b001
#define FUNC_LW 0b010
#define FUNC_LBU 0b100
#define FUNC_LHU 0b101
#define FUNC_SB 0b000
#define FUNC_SH 0b001
#define FUNC_SW 0b010
#define FUNC_ADDI 0b000
#define FUNC_SLTI 0b010
#define FUNC_SLTIU 0b011
#define FUNC_XORI 0b100
#define FUNC_ORI 0b110
#define FUNC_ANDI 0b111

#define FUNC_SLLI 0b001
#define FUNC_SRLI 0b101
#define FUNC_SRAI 0b101
#define FUNC_ADD 0b000
#define FUNC_SUB 0b000
#define FUNC_SLL 0b001
#define FUNC_SLT 0b010
#define FUNC_SLTU 0b011
#define FUNC_XOR 0b100
#define FUNC_SRL 0b101
#define FUNC_SRA 0b101
#define FUNC_OR 0b110
#define FUNC_AND 0b111

#define STR_LUI "LUI"
#define STR_AUIPC "AUIPC"
#define STR_JAL "JAL"
#define STR_JALR "JALR"
#define STR_BEQ "BEQ"
#define STR_BNE "BNE"
#define STR_BLT "BLT"
#define STR_BGE "BGE"
#define STR_BLTU "BLTU"
#define STR_BGEU "BGEU"
#define STR_LB "LB"
#define STR_LH "LH"
#define STR_LW "LW"
#define STR_LBU "LBU"
#define STR_LHU "LHU"
#define STR_SB "SB"
#define STR_SH "SH"
#define STR_SW "SW"
#define STR_ADDI "ADDI"
#define STR_SLTI "SLTI"
#define STR_SLTIU "SLTIU"
#define STR_XORI "XORI"
#define STR_ORI "ORI"
#define STR_ANDI "ANDI"
#define STR_SLLI "SLLI"
#define STR_SRLI "SRLI"
#define STR_SRAI "SRAI"
#define STR_ADD "ADD"
#define STR_SUB "SUB"
#define STR_SLL "SLL"
#define STR_SLT "SLT"
#define STR_SLTU "SLTU"
#define STR_XOR "XOR"
#define STR_SRL "SRL"
#define STR_SRA "SRA"
#define STR_OR "OR"
#define STR_AND "AND"

UINSTR(LUI, 0b0110111)
UINSTR(AUIPC, 0b0010111)
JINSTR(JAL, 0b1101111)
IINSTR(JALR, 0b1100111, 0b000)
BINSTR(BEQ, 0b1100011, 0b000)
BINSTR(BNE, 0b1100011, 0b001)
BINSTR(BLT, 0b1100011, 0b100)
BINSTR(BGE, 0b1100011, 0b101)
BINSTR(BLTU, 0b1100011, 0b110)
BINSTR(BGEU, 0b1100011, 0b111)
IINSTR(LB, 0b0000011, 0b000)
IINSTR(LH, 0b0000011, 0b001)
IINSTR(LW, 0b0000011, 0b010)
IINSTR(LBU, 0b0000011, 0b100)
IINSTR(LHU, 0b0000011, 0b101)
SINSTR(SB, 0b0100011, 0b000)
SINSTR(SH, 0b0100011, 0b001)
SINSTR(SW, 0b0100011, 0b010)
IINSTR(ADDI, 0b0010011, 0b000)
IINSTR(SLTI, 0b0010011, 0b010)
IINSTR(SLTIU, 0b0010011, 0b011)
IINSTR(XORI, 0b0010011, 0b100)
IINSTR(ORI, 0b0010011, 0b110)
IINSTR(ANDI, 0b0010011, 0b111)

#define IMM_SLLI 0b0000000
#define IMM_SRLI 0b0000000
#define IMM_SRAI 0b0100000
#define IMM_ADD 0b0000000
#define IMM_SUB 0b0100000
#define IMM_SLL 0b0000000
#define IMM_SLT 0b0000000
#define IMM_SLTU 0b0000000
#define IMM_XOR 0b0000000
#define IMM_SRL 0b0000000
#define IMM_SRA 0b0100000
#define IMM_OR 0b0000000
#define IMM_AND 0b0000000

SRINSTR(SLLI, 0b0010011, 0b001, IMM_SLLI)
SRINSTR(SRLI, 0b0010011, 0b101, IMM_SRLI)
SRINSTR(SRAI, 0b0010011, 0b101, IMM_SRAI)
RINSTR(ADD, 0b0110011, 0b000, IMM_ADD)
RINSTR(SUB, 0b0110011, 0b000, IMM_SUB)
RINSTR(SLL, 0b0110011, 0b001, IMM_SLL)
RINSTR(SLT, 0b0110011, 0b010, IMM_SLT)
RINSTR(SLTU, 0b0110011, 0b011, IMM_SLTU)
RINSTR(XOR, 0b0110011, 0b100, IMM_XOR)
RINSTR(SRL, 0b0110011, 0b101, IMM_SRL)
RINSTR(SRA, 0b0110011, 0b101, IMM_SRA)
RINSTR(OR, 0b0110011, 0b110, IMM_OR)
RINSTR(AND, 0b0110011, 0b111, IMM_AND)

#endif

#ifdef ASMGEN_RISCV_64I

#define OP_LWU 0b0000011
#define OP_LD 0b0000011
#define OP_SD 0b0100011
#define OP_ADDIW 0b0011011
#define OP_SLLIW 0b0011011
#define OP_SRLIW 0b0011011
#define OP_SRAIW 0b0011011
#define OP_ADDW 0b0111011
#define OP_SUBW 0b0111011
#define OP_SLLW 0b0111011
#define OP_SRLW 0b0111011
#define OP_SRAW 0b0111011

#define FUNC_LWU 0b110
#define FUNC_LD 0b011
#define FUNC_SD 0b011
#define FUNC_ADDIW 0b000
#define FUNC_SLLIW 0b001
#define FUNC_SRLIW 0b101
#define FUNC_SRAIW 0b101
#define FUNC_ADDW 0b000
#define FUNC_SUBW 0b000
#define FUNC_SLLW 0b001
#define FUNC_SRLW 0b101
#define FUNC_SRAW 0b101

#define STR_LWU "LWU"
#define STR_LD "LD"
#define STR_SD "SD"
#define STR_ADDIW "ADDIW"
#define STR_SLLIW "SLLIW"
#define STR_SRLIW "SRLIW"
#define STR_SRAIW "SRAIW"
#define STR_ADDW "ADDW"
#define STR_SUBW "SUBW"
#define STR_SLLW "SLLW"
#define STR_SRLW "SRLW"
#define STR_SRAW "SRAW"

IINSTR(LWU, 0b0000011, 0b110)
IINSTR(LD, 0b0000011, 0b011)
SINSTR(SD, 0b0100011, 0b011)
IINSTR(ADDIW, 0b0011011, 0b000)
RINSTR(SLLIW, 0b0011011, 0b001, IMM_SLLI)
RINSTR(SRLIW, 0b0011011, 0b101, IMM_SRLI)
RINSTR(SRAIW, 0b0011011, 0b101, IMM_SRAI)
RINSTR(ADDW, 0b0111011, 0b000, IMM_ADD)
RINSTR(SUBW, 0b0111011, 0b000, IMM_SUB)
RINSTR(SLLW, 0b0111011, 0b001, IMM_SLL)
RINSTR(SRLW, 0b0111011, 0b101, IMM_SRL)
RINSTR(SRAW, 0b0111011, 0b101, IMM_SRA)

#endif

#ifdef ASMGEN_RISCV_32M

RINSTR(MUL, 0b0110011, 0b0, 1)
RINSTR(MULH, 0b0110011, 0b1, 1)
RINSTR(MULHSU, 0b0110011, 0b10, 1)
RINSTR(MULHU, 0b0110011, 0b11, 1)
RINSTR(DIV, 0b0110011, 0b100, 1)
RINSTR(DIVU, 0b0110011, 0b101, 1)
RINSTR(REM, 0b0110011, 0b110, 1)
RINSTR(REMU, 0b0110011, 0b111, 1)

#ifdef ASMGEN_RISCV_64M
RINSTR(MULW, 0b0111011, 0b0, 1)
RINSTR(DIVW, 0b0111011, 0b100, 1)
RINSTR(DIVUW, 0b0111011, 0b101, 1)
RINSTR(REMW, 0b0111011, 0b110, 1)
RINSTR(REMUW, 0b0111011, 0b111, 1)
#endif

#endif

#ifdef ASMGEN_RISCV_32A
#define AINSTR(Name, Op, Func1, Func2)                                                   \
	inline static void asmgen_##Name(unsigned rd, unsigned rs2, unsigned rs1, int flag, char **p) { \
		struct r_type t = { .opcode = Op,                                                \
			                .rd = (unsigned) rd,                                         \
			                .funct3 = Func1,                                             \
			                .rs1 = (unsigned) rs1,                                       \
			                .rs2 = (unsigned) rs2,                                       \
			                .funct7 = (unsigned)(Func2 << 2) | flag };                   \
		*((struct r_type *) *p) = t;                                                     \
		*p += sizeof(struct r_type);                                                     \
	}

#define ACQUIRE 2
#define RELEASE 1

AINSTR(AMOADD_W, 0b0101111, 0b010, 0)
AINSTR(AMOSWAP_W, 0b0101111, 0b010, 1)

#ifdef ASMGEN_RISCV_64A

AINSTR(AMOADD_D, 0b0101111, 0b011, 0)
AINSTR(AMOSWAP_D, 0b0101111, 0b011, 1)

#endif

#endif

#ifdef ASMGEN_RISCV_ZICSR

#define CSRINSTR(Name, Op, Func)                                                   \
	inline static void asmgen_##Name(unsigned csr, unsigned rd, unsigned rs1, char **p) { \
		struct i_type t = { .opcode = Op, .rd = (unsigned) rd, .funct3 = Func, .rs1 = (unsigned) rs1 }; \
		i_type_imm(&t, csr);                                                                            \
		*((struct i_type *) *p) = t;                                                                    \
		*p += sizeof(struct i_type);                                                                    \
	}

#define PINSTR(Name, Op, Rd, Func, Rs1, Rs2, Imm) \
inline static void asmgen_##Name(char **p) { \
    struct i_type t = { .opcode = Op, .rd = (unsigned) Rd, .funct3 = Func, .rs1 = (unsigned) Rs1 }; \
    i_type_imm(&t, ((Imm) << 5) | ((Rs2) & 0x1f));                                                                            \
    *((struct i_type *) *p) = t;                                                                    \
    *p += sizeof(struct i_type);                                                                    \
}

CSRINSTR(CSRRW, 0b1110011, 0b1)
CSRINSTR(CSRRS, 0b1110011, 0b10)
CSRINSTR(CSRRC, 0b1110011, 0b11)
CSRINSTR(CSRRWI, 0b1110011, 0b101)
CSRINSTR(CSRRSI, 0b1110011, 0b110)
CSRINSTR(CSRRCI, 0b1110011, 0b111)

PINSTR(SRET, 0b1110011, 0, 0, 0, 0b10, 0b1000)
PINSTR(ECALL, 0b1110011, 0, 0, 0, 0b0, 0b000)

#endif
