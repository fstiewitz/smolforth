\ TUT Object files contain symbols. These symbols are typically unique. If you have
\ TUT two C functions with the same name, the linker complains about multiple definitions.
\ TUT In Forth, however, rewriting words is no issue. Additionally, you can have two words
\ TUT with the same name, but in different word lists. smolforth uses the following naming scheme:
\ TUT
\ TUT  - Symbols start with the "path" of their wordlist, separated by "$".
\ TUT  - Symbols end with their unmangled name.
\ TUT  - The `>BODY` of words has a `...$body$...` between word list path and name.
\ TUT  - The `DOES>` part of words has a `...$does$...` between word list path and name.
\ TUT
\ TUT The object file contains both local and global symbols to deal with situations like the one below.
\ TUT The global symbol `FORTH$body$FORTH_MAIN` links to the last `FORTH_MAIN`.
\ TUT
\ TUT One thing to keep in mind when combining programming languages is that Forth is a lot
\ TUT more permissive when it comes to names. Names that you cannot write in C, you cannot use in C.
\ TUT Simple as that.
\ TUT
\ TUT You can now read `example/reloc/core.S`

VARIABLE TESTVAR

10 TESTVAR !

: FORTH_MAIN
    ." Hello, World!" CR
;

: FORTH_MAIN
    FORTH_MAIN
    ." from multiple :FORTH_MAIN:s" CR
;

: FORTH_MAIN
    FORTH_MAIN
    ." How exciting!" CR
    ." TESTVAR: " TESTVAR @ . CR
;
