\ TUT Forth usually works in a single large memory space that contains both code and data.
\ TUT Smolforth also supports a split memory space where code, data and even word headers
\ TUT are separated. This mirrors other programming languages like C, where object files
\ TUT have `.text` sections for code, `.data` for initialized data and `.bss` for
\ TUT uninitialized data.
\ TUT
\ TUT !!!
\ TUT If you do not separate the memory space, then code, data and words will be put
\ TUT into a single .text section.
\ TUT !!!
\ TUT This is a problem for three reasons:
\ TUT
\ TUT 1. Your linker will probably put the code in a read-only section regardless.
\ TUT     To fix this, I provide a tool called `make-elf-writable` (`make-elf-writable FILE .text`).
\ TUT 2. Conventional wisdom dictates that is a safety hazard to have executable data
\ TUT     (but then again, you are programming in Forth, so...).
\ TUT 3. If your code is only written in forth but does not "use" forth
\ TUT     (like the code in `example/reloc`), then you don't need the word headers.
\ TUT
\ TUT You can now continue reading at example/reloc/Makefile

: SECTION ( start end flags )
    CREATE
    >R
    OVER ,
    OVER ,
    OVER ,
    ,
    DROP
    R> ,
    CURRENT @ @ ,
    DOES>
    DUP STATE SYS:ADATA !
    DUP DATA:FLAGS @ \ st flags
    DUP 1 AND 0= INVERT IF
        OVER STATE SYS:CDATA !
        OVER STATE SYS:ICDATA !
    THEN
    DUP 2 AND 0= INVERT IF
        OVER STATE SYS:IDATA !
        OVER STATE SYS:UIDATA !
        OVER STATE SYS:ICDATA !
    THEN
    DUP 4 AND 0= INVERT IF
        OVER STATE SYS:UDATA !
        OVER STATE SYS:UIDATA !
    THEN
    2DROP
;

: CSPACE
    STATE SYS:CODE
    DUP STATE SYS:ADATA !
    DUP STATE SYS:CDATA !
    STATE SYS:ICDATA !
;

.( \ Setting up a dedicated 100KB word space section ) CR

CSPACE
CREATE WORD-SPACE 100 1024 * ALLOT
WORD-SPACE DUP 100 1024 * + 0 SECTION WSPACE
' WSPACE >BODY STATE SYS:WDATA !

.( \ Setting up a dedicated 1MB UDATA section ) CR
CSPACE
.( \ Allocating space ) CR
CREATE U-SPACE 1024 1024 * ALLOT
.( \ Creating section ) CR
U-SPACE DUP 1024 1024 * + 4 SECTION USPACE
.( \ Enabling section ) CR
USPACE

.( \ Setting up a dedicated 1MB IDATA section ) CR
CSPACE
.( \ Allocating space ) CR
CREATE I-SPACE 1024 1024 * ALLOT
.( \ Creating section ) CR
I-SPACE DUP 1024 1024 * + 2 SECTION ISPACE
.( \ Enabling section ) CR
ISPACE

CSPACE
