INCLUDE0 ../../do.fth
0 S" EMBEDDED" ENVIRONMENT? AND [IF] DROP [ELSE] INCLUDE0 ../../case.fth [THEN]
0 S" STRING" ENVIRONMENT? AND [IF] DROP
    INCLUDE0 ../../string/string.fth
    0 S" EMBEDDED" ENVIRONMENT? AND [IF] DROP [ELSE] INCLUDE0 ../../string/string-code.fth [THEN]
[THEN]
0 S" EMBEDDED" ENVIRONMENT? AND [IF] DROP [ELSE] INCLUDE0 ../../core0.fth [THEN]
INCLUDE0 ../../core.fth
0 S" FILE" ENVIRONMENT? AND [IF] DROP INCLUDE0 ../../file2.fth [THEN]
0 S" SEARCH-ORDER" ENVIRONMENT? AND [IF] DROP INCLUDE0 ../../search.fth [THEN]
0 S" TOOLS" ENVIRONMENT? AND [IF] DROP INCLUDE0 ../../tools.fth [THEN]
0 S" DOUBLE" ENVIRONMENT? AND [IF] DROP INCLUDE0 ../../double.fth [THEN]
0 S" STRING-EXT" ENVIRONMENT? AND [IF] DROP
    INCLUDE0 ../../string/string1.fth
    0 S" MEMORY-ALLOC" ENVIRONMENT? AND [IF] DROP
        INCLUDE0 ../../string/string2.fth
    [THEN]
[THEN]
0 S" EMBEDDED" ENVIRONMENT? AND [IF] DROP [ELSE] INCLUDE0 ../../defer.fth [THEN]
0 S" FACILITY" ENVIRONMENT? AND [IF] DROP INCLUDE0 ../../facility.fth [THEN]
0 S" BLOCK" ENVIRONMENT? AND [IF] DROP
    INCLUDE0 ../../block.fth
    INCLUDE0 ../../editor.fth
[THEN]
0 S" FLOATING" ENVIRONMENT? AND [IF] DROP INCLUDE0 ../../float.fth [THEN]
INCLUDE0 ../../asm.fth