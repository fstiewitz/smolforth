8 CONSTANT BUFFER-COUNT
CREATE BUFFERS 1024 BUFFER-COUNT * ALLOT
CREATE BUFFER-ASSOC BUFFER-COUNT CELLS ALLOT
CREATE BUFFER-FLAGS BUFFER-COUNT ALLOT

VARIABLE BUFFER-I 0 BUFFER-I !

BUFFER-ASSOC BUFFER-COUNT CELLS 0 FILL

: UPDATE-BUFFER
    >R
    BUFFER-FLAGS R@ + C@ IF
        BUFFER-ASSOC R@ CELLS + @ ?DUP IF
            BUFFERS R@ 1024 * +
            1 BLOCK-OP
        THEN
    THEN
    R> DROP
;

: ?BUFFER ( n -- addr 0 | addr 1 )
    BUFFER-COUNT 0 DO
        DUP BUFFER-ASSOC I CELLS + @ = IF
            DROP
            BUFFERS I 1024 * +
            I BUFFER-I !
            0
            UNLOOP
            EXIT
        THEN
    LOOP
    BUFFER-COUNT 0 DO
        BUFFER-ASSOC I CELLS + @ 0= IF
            BUFFER-ASSOC I CELLS + !
            0 BUFFER-FLAGS I + C!
            BUFFERS I 1024 * +
            I BUFFER-I !
            TRUE
            UNLOOP
            EXIT
        THEN
    LOOP
    1 BUFFER-I +!
    BUFFER-I @ BUFFER-COUNT MOD BUFFER-I !
    BUFFER-I @ UPDATE-BUFFER
    0 BUFFER-FLAGS BUFFER-I @ + C!
    BUFFER-ASSOC BUFFER-I @ CELLS + !
    BUFFERS BUFFER-I @ 1024 * +
    TRUE
;

: BUFFER ?BUFFER DROP ;

: BLOCK ( n -- addr )
    DUP ?BUFFER IF
        DUP >R 0 BLOCK-OP R>
    ELSE
        SWAP DROP
    THEN
;

: UPDATE
    1 BUFFER-FLAGS BUFFER-I @ + C!
;

: FLUSH
    BUFFER-COUNT 0 DO
        BUFFER-ASSOC I CELLS + @ 0= INVERT IF
            I UPDATE-BUFFER
        THEN
        0 BUFFER-ASSOC I CELLS + !
        0 BUFFER-FLAGS I + C!
    LOOP
;

: SAVE-BUFFERS
    BUFFER-COUNT 0 DO
        BUFFER-ASSOC I CELLS + @ 0= INVERT IF
            I UPDATE-BUFFER
        THEN
        0 BUFFER-FLAGS I + C!
    LOOP
;

: EMPTY-BUFFERS
    BUFFER-COUNT 0 DO
        0 BUFFER-ASSOC I CELLS + !
        0 BUFFER-FLAGS I + C!
    LOOP
;

: LOAD
    SAVE-INPUT N>R
    0 SOURCE-ID!
    DUP BLK !
    BLOCK 1024 ['] EVALUATE-RAW CATCH DROP \ TODO catch exceptions
    NR> RESTORE-INPUT DROP
;

: THRU
    1+ SWAP DO
        I LOAD
    LOOP
;
