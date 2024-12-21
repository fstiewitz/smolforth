.macro FREG_S_var src, dest
FREG_S \src, \dest, t6
.endm

.macro FREG_L_var dest, src
FREG_L \dest, \src
.endm

.macro SFREG_S src, dest
#if __riscv_xlen == 64
fcvt.s.d fa7, \src
fsw fa7, \dest
#elif __riscv_xlen == 32
fsw \src, \dest
#endif
.endm

.macro SFREG_L dest, src
#if __riscv_xlen == 64
flw \dest, \src
fcvt.d.s \dest, \dest
#elif __riscv_xlen == 32
flw \dest, \src
#endif
.endm

.macro DFREG_S src, dest
#if __riscv_xlen == 64
fsd \src, \dest
#elif __riscv_xlen == 32
fcvt.d.s fa7, \src
fsd fa7, \dest
#endif
.endm

.macro DFREG_L dest, src
#if __riscv_xlen == 64
fld \dest, \src
#elif __riscv_xlen == 32
fld \dest, \src
fcvt.s.d \dest, \dest
#endif
.endm

.macro stack_ffetch reg, num
FREG_L \reg, -\num*FWORDSIZE (s2)
.endm

.macro stack_fstore reg, num
FREG_S \reg, -\num*FWORDSIZE (s2)
.endm

.macro stack_fshrink num
addi s2, s2, -\num*FWORDSIZE
.endm

.macro stack_fgrow num
addi s2, s2, \num*FWORDSIZE
.endm

.macro stack_fpop reg
addi s2, s2, -FWORDSIZE
FREG_L \reg, 0(s2)
.endm

.macro stack_fpush reg
FREG_S \reg, 0(s2)
addi s2, s2, FWORDSIZE
.endm

.macro mv_f_r ireg, freg
#if __riscv_xlen == 64
fmv.x.d \ireg, \freg
#elif __riscv_xlen == 32
fmv.x.w \ireg, \freg
#endif
.endm

.macro mv_f_f dreg, sreg
#if __riscv_xlen == 64
fmv.d \dreg, \sreg
#elif __riscv_xlen == 32
fmv.s \dreg, \sreg
#endif
.endm

.macro fli freg, imm, tmp
#if __riscv_xlen == 64
    li \tmp, 10
    fcvt.d.l \freg, \tmp
#elif __riscv_xlen == 32
    li \tmp, 10
    fcvt.s.w \freg, \tmp
#endif
.endm

.macro fcvtx freg, reg
#if __riscv_xlen == 64
    fcvt.d.l \freg, \reg
#elif __riscv_xlen == 32
    fcvt.s.w \freg, \reg
#endif
.endm

#if __riscv_xlen == 64
#define fabsx fabs.d
#define fclassx fclass.d
#define feqx feq.d
#define flex fle.d
#define fltx flt.d
#define faddx fadd.d
#define fsubx fsub.d
#define fmulx fmul.d
#define fdivx fdiv.d
#define fnegx fneg.d
#define fsqrtx fsqrt.d
#define fminx fmin.d
#define fmaxx fmax.d
#define fsgnjx fsgnj.d
#define acoshx acosh
#define acosx acos
#define asinhx asinh
#define asinx asin
#define atan2x atan2
#define atanhx atanh
#define atanx atan
#define coshx cosh
#define cosx cos
#define expm1x expm1
#define expx exp
#define floorx floor
#define log10x log10
#define log1px log1p
#define logx log
#define powx pow
#define roundx round
#define sinhx sinh
#define sinx sin
#define tanhx tanh
#define tanx tan
#elif __riscv_xlen == 32
#define fabsx fabs.s
#define fclassx fclass.s
#define feqx feq.s
#define flex fle.s
#define fltx flt.s
#define faddx fadd.s
#define fsubx fsub.s
#define fmulx fmul.s
#define fdivx fdiv.s
#define fnegx fneg.s
#define fsqrtx fsqrt.s
#define fminx fmin.s
#define fmaxx fmax.s
#define fsgnjx fsgnj.s
#define acoshx acoshf
#define acosx acosf
#define asinhx asinhf
#define asinx asinf
#define atan2x atan2f
#define atanhx atanhf
#define atanx atanf
#define coshx coshf
#define cosx cosf
#define expm1x expm1f
#define expx expf
#define floorx floorf
#define log10x log10f
#define log1px log1pf
#define logx logf
#define powx powf
#define roundx roundf
#define sinhx sinhf
#define sinx sinf
#define tanhx tanhf
#define tanx tanf
#endif

.macro nan_propagate dest, src0, src1, tmp0
    fclassx \tmp0, \src0
    andi \tmp0, \tmp0, 0x300
    beqz \tmp0, .nan_propagate_next\@
    fsgnjx \dest, \dest, \src0
    j .nan_propagate_end\@
.nan_propagate_next\@:
    fclassx \tmp0, \src1
    andi \tmp0, \tmp0, 0x300
    beqz \tmp0, .nan_propagate_end\@
    fsgnjx \dest, \dest, \src1
.nan_propagate_end\@:
.endm

.macro nan_propagate1 dest, src, tmp0
    fclassx \tmp0, \src
    andi \tmp0, \tmp0, 0x300
    beqz \tmp0, .nan_propagate_end\@
    fsgnjx \dest, \dest, \src
.nan_propagate_end\@:
.endm
