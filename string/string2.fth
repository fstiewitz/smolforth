: 4DUP
    3 PICK
    3 PICK
    3 PICK
    3 PICK
;

VOCABULARY SUBST

: S-APPEND ( c1 n1 c2 n2 c3 n3 -- c1 n1 c2 n2 )
    DUP 3 PICK > THROW
    4DUP 2SWAP ROT NIP MOVE \ c1 n1 c2 n2 c3 n3
    NIP /STRING \ c1 n1 c2 n2
;

: SUBSTITUTE0
    2DUP 2>R
    0 >R 0 >R 0 >R
    BEGIN \ c1 n1 c2 n2 | R: c2 n2 #sub %addr state
        DUP 0= INVERT >R
        2 PICK 0= INVERT R> AND
    WHILE
        \ R@ . 2OVER TYPE CR
        R@ CASE
            1 OF
                2OVER DROP C@ DUP [CHAR] % = IF
                    DROP
                    R> R> NIP 0 >R 0 >R
                    \ c1 n1 c2 n2 s1
                    4 PICK OVER -
                    ?DUP IF
                        \ case %foo%
                        \ 2DUP TYPE ."  -> "
                        2DUP ['] SUBST >BODY SEARCH-WORDLIST IF
                            \ DUP .
                            \ DUP NAME>STRING TYPE SPACE
                            >R 2DROP R> EXECUTE
                            \ 2DUP DUP . TYPE
                            R> R> R> 1+ >R >R >R
                            S-APPEND
                        ELSE
                            \ ." %" 2DUP TYPE ." %"
                            2>R
                            S" %" S-APPEND
                            2R> S-APPEND
                            S" %" S-APPEND
                        THEN
                        \ CR
                    ELSE
                        DROP
                        \ case %%
                        S" %"
                        S-APPEND
                    THEN
                    2SWAP 1 /STRING 2SWAP
                ELSE
                    DROP
                    2SWAP 1 /STRING 2SWAP
                THEN
            ENDOF
            0 OF
                2OVER DROP C@ DUP [CHAR] % = IF
                    DROP
                    R> R> 2DROP 3 PICK 1+ >R 1 >R
                    2SWAP 1 /STRING 2SWAP
                ELSE
                    2 PICK C!
                    1 /STRING 2SWAP 1 /STRING 2SWAP
                THEN
            ENDOF
        ENDCASE
    REPEAT
    2 PICK THROW
    R> IF
        S" %"
        S-APPEND
        R> 4 PICK OVER - S-APPEND
    ELSE
        R> DROP
    THEN
    R> 2R> ROT >R 2>R
    2SWAP 2DROP
    2R> 2SWAP NIP -
    \ R@ NEGATE . DUP . ." |" 2DUP TYPE ." |" CR
    R>
;

: TMP-COPY ( c-addr u -- c-addr u )
    DUP IF
        DUP ALLOCATE ABORT" COULD NOT ALLOCATE TEMPORARY BUFFER" SWAP 2DUP 2>R MOVE
        2R>
    THEN
;

: SUBSTITUTE ( c-addr u c-addr u -- c-addr u n )
    2SWAP TMP-COPY 2DUP 2>R 2SWAP
    ['] SUBSTITUTE0 CATCH IF
        2DROP -1
    THEN
    2R> IF FREE THEN DROP
;

: RC >CREATE 0 0 , , DOES> 2@ ;

: REPLACES ( c1 n1 c2 n2 -- )
    2DUP ['] SUBST >BODY SEARCH-WORDLIST INVERT IF
        CURRENT @ >R
        ALSO SUBST DEFINITIONS
        RC
        CURRENT @ @
        PREVIOUS
        R> CURRENT !
    ELSE
        >R 2DROP R>
    THEN
    >BODY
    DUP 2@ DROP FREE DROP
    OVER ALLOCATE ABORT" CANNOT ALLOCATE MEMORY FOR SUBSTITUTION" \ c1 n1 body alloc
    DUP >R
    OVER CELL+ ! \ c1 n1 body
    2DUP ! \ c1 n1 body
    DROP R>
    SWAP MOVE
;

