INCLUDE0 ../../case.fth
INCLUDE0 ../../string/string.fth
INCLUDE0 ../../string/string-code.fth
INCLUDE0 ../../core0.fth
INCLUDE0 ../../core.fth
INCLUDE0 ../../file2.fth
INCLUDE0 ../../search.fth
INCLUDE0 ../../tools.fth
INCLUDE0 ../../string/string2.fth
INCLUDE0 ../../defer.fth
0 S" EMBEDDED" ENVIRONMENT? AND INVERT [IF]
    0 S" RISCV" ENVIRONMENT? AND [IF] DROP
        S" OPTIMIZATION-LEVEL" ENVIRONMENT? DROP 0 <> [IF]
            INCLUDE0 ../../asm/rv.fth
            INCLUDE0 ../../asm/code.fth
            S" OPTIMIZATION-LEVEL" ENVIRONMENT? DROP 2 = [IF]
                INCLUDE0 ../../asm/optim.fth
            [THEN]
            INCLUDE0 ../../asm/rv-core.fth
            S" OPTIMIZATION-LEVEL" ENVIRONMENT? DROP 2 = [IF]
                INCLUDE0 ../../asm/rv-optim.fth
            [THEN]
        [THEN]
    [THEN]
[ELSE] DROP [THEN]
