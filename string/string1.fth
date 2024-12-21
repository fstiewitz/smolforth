: S, ( c c-addr n -- c-addr n )
    DUP 0 > INVERT ABORT" CANNOT ESCAPE S STRING"
    >R
    2DUP C!
    NIP
    R>
    1 /STRING
;

: SESCAPE ( c-addr n -- c-addr n )
    2DUP 2>R 2>R
    0
    BEGIN
        SOURCE
        >IN @
        2DUP > >R
        2 PICK OVER + C@ [CHAR] " = >R
        3 PICK R> INVERT OR R> AND
    WHILE \ state source-addr source-len >in
        3 PICK CASE
            3 OF
                2 PICK OVER + C@
                DUP [CHAR] 0 [CHAR] 9 1+ WITHIN IF
                    [CHAR] 0 - 2R@ DROP C@ OR 2R> S, 2>R
                ELSE
                    DUP [CHAR] A [CHAR] F 1+ WITHIN IF
                        [CHAR] A - 10 + 2R@ DROP C@ OR 2R> S, 2>R
                    ELSE
                        DUP [CHAR] a [CHAR] f 1+ WITHIN IF
                            [CHAR] a - 10 + 2R@ DROP C@ OR 2R> S, 2>R
                        ELSE
                            ABORT" INVALID ESCAPE CODE IN STRING"
                        THEN
                    THEN
                THEN
                >R >R >R DROP 0 R> R> R>
            ENDOF
            2 OF
                2 PICK OVER + C@
                DUP [CHAR] 0 [CHAR] 9 1+ WITHIN IF
                    [CHAR] 0 - 4 LSHIFT 2R@ DROP C!
                ELSE
                    DUP [CHAR] A [CHAR] F 1+ WITHIN IF
                        [CHAR] A - 10 + 4 LSHIFT 2R@ DROP C!
                    ELSE
                        DUP [CHAR] a [CHAR] f 1+ WITHIN IF
                            [CHAR] a - 10 + 4 LSHIFT 2R@ DROP C!
                        ELSE
                            ABORT" INVALID ESCAPE CODE IN STRING"
                        THEN
                    THEN
                THEN
                >R >R >R DROP 3 R> R> R>
            ENDOF
            1 OF
                >R >R >R DROP 0 R> R> R>
                2 PICK OVER + C@ CASE
                    [CHAR] a OF 7 2R> S, 2>R ENDOF
                    [CHAR] b OF 8 2R> S, 2>R ENDOF
                    [CHAR] e OF 27 2R> S, 2>R ENDOF
                    [CHAR] f OF 12 2R> S, 2>R ENDOF
                    [CHAR] l OF 10 2R> S, 2>R ENDOF
                    [CHAR] m OF 13 2R> S, 2>R 10 2R> S, 2>R ENDOF
                    [CHAR] n OF 10 2R> S, 2>R ENDOF
                    [CHAR] q OF 34 2R> S, 2>R ENDOF
                    [CHAR] r OF 13 2R> S, 2>R ENDOF
                    [CHAR] t OF 9 2R> S, 2>R ENDOF
                    [CHAR] v OF 11 2R> S, 2>R ENDOF
                    [CHAR] z OF 0 2R> S, 2>R ENDOF
                    [CHAR] " OF 34 2R> S, 2>R ENDOF
                    [CHAR] \ OF 92 2R> S, 2>R ENDOF
                    [CHAR] x OF >R >R >R DROP 2 R> R> R> ENDOF
                ENDCASE
            ENDOF
            0 OF
                2 PICK OVER + C@ DUP [CHAR] \ = IF
                    DROP
                    >R >R >R DROP 1 R> R> R>
                ELSE
                    2R> S, 2>R
                THEN
            ENDOF
        ENDCASE
        1+ >IN !
        2DROP
    REPEAT
    1+ >IN !
    2DROP DROP
    2R> NIP 2R> \ nlen c-addr olen
    ROT -
;

: S\"
    STATE @ IF
        POSTPONE AHEAD

        HERE UNUSED SESCAPE 2DUP + ORG
        ALIGN
        2>R
        POSTPONE THEN
        2R>
        SWAP NEXT-WORD SWAP COMPILE-ADDR
        0 SWAP COMPILE-CONSTANT
    ELSE
        S"CURBUF 80 SESCAPE
        S"NEXTBUF
    THEN
; IMMEDIATE
