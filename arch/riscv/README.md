## smolforth - Targets RV32 and RV64

smolforth-RV64 and smolforth-RV32 target 32-bit and 64-bit RISC-V processors.

### Required Extensions

smolforth-RVX require processors with at least `rvXim` extensions.

If `float` is enabled, `d` is also required.

### Calling Convention

The calling convention follows cdecl on RISC-V with the following differences:

1. The stack pointer is in `s0`, grows upwards, points to the free space above top.
2. The return stack pointer is in `s1`, grows upwards, points to the free space above top.
3. The (optional) floating-point stack pointer is in `s2`, grows upwards, points to the free space above top.

C functions are called with the assembly routine `sf_to_c(stack, return stack, function)`.
C functions are expected to return two values in `a0` (=stack) and `a1` (=return stack). The optional floating-point stack is stored in a variable called `fps` for the duration of the C call.

