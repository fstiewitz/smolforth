: PAD HERE 128 + ;

: ABORT-MSG!
    ERR-SIZE !
    ERR-STRING !
;

: PARSE
    >R
    SOURCE
    >IN @ /STRING
    2DUP
    BEGIN \ c0 n0 c1 n1
        2DUP
        0 > IF
            C@ R@ = INVERT
        ELSE
            DROP 0
        THEN
    WHILE
        1 /STRING
    REPEAT
    R> DROP
    SWAP DROP
    - DUP 1+ >IN +!
;

: SLITERAL ( c-addr u -- )
    >R >R
    POSTPONE AHEAD
    R> R>
    DUP 0= INVERT IF
        2DUP
        HERE >R
        0 DO
            DUP I + C@ C,
        LOOP
        ALIGN
        DROP
    ELSE
        HERE >R
    THEN
    SWAP DROP R> SWAP
    >R >R
    POSTPONE THEN
    R> R>
    SWAP NEXT-WORD SWAP COMPILE-ADDR
    0 SWAP COMPILE-CONSTANT
; IMMEDIATE

CREATE S"BUF 160 CHARS ALLOT
VARIABLE S"BUFNEXT
0 S"BUFNEXT !
: S"CURBUF S"BUFNEXT @ 80 * S"BUF + ;
: S"NEXTBUF S"BUFNEXT @ 1 + 2 MOD S"BUFNEXT ! ;

: S"
    STATE @ IF
        [CHAR] " PARSE
        POSTPONE SLITERAL
    ELSE
        [CHAR] " PARSE
        DUP >R S"CURBUF SWAP CMOVE
        S"CURBUF R>
        S"NEXTBUF
    THEN
; IMMEDIATE

: ,"
    [CHAR] " PARSE
    DUP C,
    0 ?DO
        DUP I + C@ C,
    LOOP
    DROP
; IMMEDIATE

: C"
    POSTPONE AHEAD
    HERE >R
    POSTPONE ,"
    ALIGN
    POSTPONE THEN
    NEXT-WORD R> COMPILE-ADDR
; IMMEDIATE

: ."
    POSTPONE S"
    POSTPONE TYPE
; IMMEDIATE

: .(
    [CHAR] ) PARSE TYPE
; IMMEDIATE

: ABORT"
    POSTPONE IF
    POSTPONE S"
    POSTPONE ABORT-MSG!
    -2 POSTPONE LITERAL
    POSTPONE THROW
    POSTPONE THEN
; IMMEDIATE
