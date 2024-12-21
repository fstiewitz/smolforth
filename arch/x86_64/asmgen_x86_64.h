#pragma once

#include<stdint.h>

#define RAX 0
#define RCX 1
#define RDX 2
#define RBX 3
#define RSP 4
#define RBP 5
#define RSI 6
#define RDI 7
#define R14 14
#define R15 15

#define XMM0 0

#define REX 0x40
#define REX_W 0x08
#define REX_R 0x04
#define REX_X 0x02
#define REX_B 0x01

inline static void asmgen_PUSHQ_R64(int r, char **h) {
    *((*h)++) = 0x50 + r;
}

inline static void asmgen_POPQ_R64(int r, char **h) {
    *((*h)++) = 0x58 + r;
}

inline static void asmgen_RET(char **h) {
    *((*h)++) = 0xC3;
}

inline static void asmgen_SHL_IMM(int r, int imm, char **h) {
    if(r >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
        *((*h)++) = 0xC1;
        *((*h)++) = 0xE0 | (r & 7);
        *((*h)++) = imm;
    } else {
        *((*h)++) = REX | REX_W;
        *((*h)++) = 0xC1;
        *((*h)++) = 0xE0 | (r & 7);
        *((*h)++) = imm;
    }
}

inline static void asmgen_SHR_IMM(int r, int imm, char **h) {
    if(r >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
        *((*h)++) = 0xC1;
        *((*h)++) = 0xE8 | (r & 7);
        *((*h)++) = imm;
    } else {
        *((*h)++) = REX | REX_W;
        *((*h)++) = 0xC1;
        *((*h)++) = 0xE8 | (r & 7);
        *((*h)++) = imm;
    }
}

inline static void asmgen_OR(int dest, int src, char **h) {
    int x = REX | REX_W;
    if(dest >= 8) x |= REX_B;
    if(src >= 8) x |= REX_R;
    *((*h)++) = x;
    *((*h)++) = 0x09;
    *((*h)++) = ((dest & 7) << 3) | (src & 7);
}

inline static void asmgen_ADD_IMM(int r, int imm, char **h) {
    if(r >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
    } else {
        *((*h)++) = REX | REX_W;
    }
    *((*h)++) = 0x83;
    *((*h)++) = 0xC0 | (r & 7);
    *((*h)++) = imm;
}

inline static void asmgen_CALL_REL32(int r, char **h) {
    *((*h)++) = 0xE8;
    *(int32_t*)(*h) = r - 5;
    *h += 4;
}

inline static void asmgen_CALL(int r, char **h) {
    *((*h)++) = 0xFF;
    *((*h)++) = 0xD0 | (r & 7);
}

inline static void asmgen_JMP_REL32(int r, char **h) {
    *((*h)++) = 0xE9;
    *(int32_t*)(*h) = r - 5;
    *h += 4;
}

inline static void asmgen_JMP(int r, char **h) {
    *((*h)++) = 0xFF;
    *((*h)++) = 0xE0 | (r & 7);
}

inline static void asmgen_LEA_REL32(int reg, intptr_t r, char **h) {
    int32_t rel = (r - (intptr_t)*h);
    if(reg >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
    } else {
        *((*h)++) = REX | REX_W;
    }
    *((*h)++) = 0x8D;
    *((*h)++) = ((reg & 7) << 3) | 0x5;
    *(int32_t*)(*h) = rel - 7;
    *h += 4;
}

inline static void asmgen_MOV_TAKE_REL32(int reg, intptr_t r, char **h) {
    int32_t rel = (r - (uintptr_t)*h);
    if(reg >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
    } else {
        *((*h)++) = REX | REX_W;
    }
    *((*h)++) = 0x8B;
    *((*h)++) = ((reg & 7) << 3) | 0x5;
    *(int32_t*)(*h) = rel - 7;
    *h += 4;
}


inline static void asmgen_MOV_IMM32(int reg, int imm, char **h) {
    if(reg >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
    } else {
        *((*h)++) = REX | REX_W;
    }
    *((*h)++) = 0xC7;
    *((*h)++) = 0xC0 | (reg & 7);
    *(int32_t*)(*h) = imm;
    *h += 4;
}

inline static void asmgen_MOV_IMM64(int reg, uint64_t imm, char **h) {
    if(reg >= 8) {
        *((*h)++) = REX | REX_W | REX_B;
    } else {
        *((*h)++) = REX | REX_W;
    }
    *((*h)++) = 0xBB;
    *(uint64_t*)(*h) = imm;
    *h += 8;
}

inline static void asmgen_MOVQ_R64_XMM(int from, int to, char **h) {
    *((*h)++) = 0x66;
    int x = REX | REX_W;
    if(to >= 8) x |= REX_X;
    if(from >= 8) x |= REX_B;
    *((*h)++) = x;
    *((*h)++) = 0x0F;
    *((*h)++) = 0x6E;
    *((*h)++) = 0xC0 | ((to & 7) << 3) | (from & 7);
}

inline static void asmgen_MOVQ_PUT(int dest, int src, char **h) {
    int x = REX | REX_W;
    if(dest >= 8) x |= REX_X;
    if(src >= 8) x |= REX_B;
    *((*h)++) = x;
    *((*h)++) = 0x89;
    *((*h)++) = ((dest & 7) << 3) | (src & 7);
}

inline static void asmgen_MOVQ_PUT_XMM(int src, int dest, char **h) {
    *((*h)++) = 0x66;
    int x = REX | REX_W;
    if(src >= 8) x |= REX_X;
    if(dest >= 8) x |= REX_B;
    *((*h)++) = x;
    *((*h)++) = 0x0F;
    *((*h)++) = 0x7E;
    *((*h)++) = ((src & 7) << 3) | (dest & 7);
}

inline static void asmgen_MOVQ_TAKE(int src, int dest, char **h) {
    int x = REX | REX_W;
    if(dest >= 8) x |= REX_X;
    if(src >= 8) x |= REX_B;
    *((*h)++) = x;
    *((*h)++) = 0x8B;
    *((*h)++) = ((dest & 7) << 3) | (src & 7);
}

inline static void asmgen_BEQ_IMM(int reg, int imm, int32_t offset, char **h) {
    int x = REX | REX_W;
    if(reg >= 8) x |= REX_B;
    *((*h)++) = x;
    *((*h)++) = 0x83;
    *((*h)++) = 0xC0 | (7 << 3) | (reg & 7);
    *((*h)++) = imm;

    *((*h)++) = 0x0f;
    *((*h)++) = 0x84;
    *(int32_t*)(*h) = offset - 10;
    *h += 4;
}
