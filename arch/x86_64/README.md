## smolforth - Target x86_64

smolforth-x86_64 targets 64-bit X86_64 processors.

### Calling Convention

The calling convention follows cdecl on x86_64 with the following differences:

1. The (data) stack pointer is in `r15`, grows upwards, points to the free space above top.
2. The return stack pointer is in `rsp`, grows downwards.
3. The (optional) floating-point stack pointer is in `r14`, grows upwards, points to the free space above top.

C functions are called with the assembly routine `sf_to_c(stack, return stack, function)`.
C functions are expected to return two values in `rax` (=stack) and `rdx` (=return stack).
