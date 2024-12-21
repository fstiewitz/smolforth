.macro FREG_S src, dest
movq \src, \dest
.endm

.macro FREG_L dest, src
movq \src, \dest
.endm

.macro SFREG_S src, dest
    cvtsd2ss \src, ft0
    movd ft0, \dest
.endm

.macro SFREG_L dest, src
    movd \src, ft0
    cvtss2sd ft0, \dest
.endm

.macro DFREG_S src, dest
movq \src, \dest
.endm

.macro DFREG_L dest, src
movq \src, \dest
.endm

.macro stack_fpop reg
addq $-WORDSIZE, %r14
movq (%r14), \reg
.endm

.macro stack_fpush reg
movq \reg, (%r14)
addq $WORDSIZE, %r14
.endm

.macro mv_f_r ireg, freg
movq \freg, \ireg
.endm

.macro mv_r_f freg, ireg
movq \ireg, \freg
.endm

.macro mv_f_f dreg, sreg
movq \sreg, \dreg
.endm

.macro stack_ffetch reg, num
movq -\num*WORDSIZE (%r14), \reg
.endm

.macro stack_fstore reg, num
movq \reg, -\num*WORDSIZE (%r14)
.endm

.macro stack_fshrink num
addq $-\num*WORDSIZE, %r14
.endm

.macro stack_fgrow num
addq $\num*WORDSIZE, %r14
.endm

.macro stack_fpop0
    addq $-WORDSIZE, %r14
    fldl (%r14)
.endm

.macro stack_fpush0
    fstpl (%r14)
    addq $WORDSIZE, %r14
.endm

.macro stack_ffetch0 num
    fldl -\num*WORDSIZE (%r14)
.endm

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
