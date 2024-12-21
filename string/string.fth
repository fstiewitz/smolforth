: -TRAILING ( c-addr u -- c-addr u )
    2DUP + 1-
    BEGIN
        DUP C@ 32 = >R
        OVER 0 = INVERT
        R> AND
    WHILE
        1- SWAP 1- SWAP
    REPEAT
    DROP
;

: /STRING ( c-addr u n -- c-addr u )
    DUP >R
    - SWAP R> +
    SWAP
;

: CMOVE
    DUP 0 > IF
        0 DO
            2DUP SWAP C@ SWAP C!
            1+ SWAP 1+ SWAP
        LOOP
        2DROP
    ELSE
        DROP 2DROP
    THEN
;

: CMOVE>
    DUP 0 > IF
        DUP >R
        + SWAP R@ + SWAP
        1- SWAP 1- SWAP
        R> 0 DO
            2DUP SWAP C@ SWAP C!
            1- SWAP 1- SWAP
        LOOP
        2DROP
    ELSE
        DROP 2DROP
    THEN
;

: MOVE
    >R 2DUP > IF
        R> CMOVE
    ELSE
        R> CMOVE>
    THEN
;

: COMPARE ( c-addr u c-addr u -- n )
    >R SWAP R> ( c-addr c-addr u u )
    BEGIN
        2DUP 0= 1 AND SWAP 0= 2 AND OR CASE
            1 OF 2DROP 2DROP 1 EXIT ENDOF
            2 OF 2DROP 2DROP -1 EXIT ENDOF
            3 OF 2DROP 2DROP 0 EXIT ENDOF
        ENDCASE
        3 PICK C@ 3 PICK C@ - DUP 0= IF
            DROP
            1- SWAP 1- SWAP >R >R
            1+ SWAP 1+ SWAP R> R>
        ELSE
            0 > >R
            2DROP 2DROP
            R> IF
                1
            ELSE
                -1
            THEN
            EXIT
        THEN
    AGAIN
;

: BLANK BL FILL ;
: ERASE 0 FILL ;

: SEARCH
    DUP 0= IF 2DROP -1 EXIT THEN
    2OVER >R >R
    BEGIN
        >R OVER R@ < INVERT
        R> SWAP
    WHILE
        2OVER \ c1 n1 c2 n2 c1 n1
        DROP OVER
        3 PICK \ c1 n1 c2 n2 c1 n2 c2
        OVER \ c1 n1 c2 n2 c1 n2 c2 n2
        COMPARE 0 = IF
            2DROP
            R> R> 2DROP
            -1
            EXIT
        THEN
        >R >R
        1 /STRING
        R> R>
    REPEAT
    2DROP
    2DROP
    R> R>
    0
;

: .R
    >R
    DUP ABS 0 <# #S ROT SIGN #>
    DUP R> - DUP 0 < IF
        NEGATE SPACES
    ELSE
        DROP
    THEN
    TYPE SPACE
;

: U.R
    >R
    0 <# #S #>
    DUP R> - DUP 0 < IF
        NEGATE SPACES
    ELSE
        DROP
    THEN
    TYPE SPACE
;

: UNESCAPE
    DUP 2SWAP OVER + SWAP ?DO
        I C@ [CHAR] % = IF
            [CHAR] % OVER C! 1+
        THEN
        I C@ OVER C! 1+
    LOOP
    OVER
    -
;
