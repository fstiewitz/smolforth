DECIMAL
ONLY FORTH
VOCABULARY MEMORY-ALLOC
ALSO MEMORY-ALLOC DEFINITIONS

0 VALUE ALLOCATION-AREA

BEGIN-STRUCTURE ALLOC:BIGH
    FIELD: BIGH:SIZE
END-STRUCTURE

BEGIN-STRUCTURE ALLOC:SMALLH
    FIELD: ALLOC:SIZE
    FIELD: ALLOC:USED
    FIELD: ALLOC:PREV
    FIELD: ALLOC:NEXT
END-STRUCTURE

: FIND-FREE-AREA ( u smallh -- smallh )
    DUP ALLOC:USED @ IF
        ALLOC:NEXT @ ?DUP IF
            RECURSE
        ELSE
            DROP 0
        THEN
    ELSE
        DUP ALLOC:SIZE @ 2 PICK ALLOC:SMALLH + U> IF
            NIP
        ELSE
            ALLOC:NEXT @ ?DUP IF
                RECURSE
            ELSE
                DROP 0
            THEN
        THEN
    THEN
;

: IS-PERFECT-FIT? ( u size -- flag )
    2DUP = IF 2DROP -1 EXIT THEN
    0 ROT 0 \ sd ud
    D- ALLOC:SMALLH 1+ S>D D<
;

: SPLIT-ALLOCATE ( u smallh -- addr )
    SWAP >R
    DUP ALLOC:SIZE @ R@ SWAP IS-PERFECT-FIT? IF \ perfect fit?
        DUP ALLOC:USED -1 SWAP !
        R> DROP
        ALLOC:SMALLH +
    ELSE \ smallh
        \ DUP . DUP ALLOC:SIZE @ . R@ .
        \ DUP ALLOC:NEXT @ .
        \ ." SPLIT-ALLOCATE" CR
        DUP ALLOC:USED -1 SWAP !
        DUP R@ + ALLOC:SMALLH +
        OVER ALLOC:NEXT @
        \ smallh betw-h next-h
        \ prev pointers first
        DUP IF 2DUP ALLOC:PREV ! THEN
        >R 2DUP ALLOC:PREV ! R>
        \ next pointers next
        2DUP SWAP ALLOC:NEXT !
        >R 2DUP SWAP ALLOC:NEXT ! R>
        \ sizes & used
        DROP OVER DUP ALLOC:SMALLH + SWAP ALLOC:SIZE @ +
        2DUP SWAP ALLOC:SMALLH + - 2 PICK ALLOC:SIZE !
        DROP
        ALLOC:USED 0 SWAP !
        DUP ALLOC:SIZE R> SWAP !
        ALLOC:SMALLH +
    THEN
;

: DEBUG-MEMORY-ALLOCATION
    ALLOCATION-AREA ALLOC:BIGH +
    BEGIN
        DUP ALLOC:SIZE @ OVER ALLOC:USED @ INVERT IF
            NEGATE
        THEN
        OVER U. OVER ALLOC:SMALLH + U. .
        ALLOC:NEXT @ DUP U. CR DUP 0=
    UNTIL
    DROP
;

: INIT-ALLOCATION-AREA ( addr size -- )
    OVER ALLOC:SIZE !
    DUP ALLOC:BIGH + \ addr mem-start
    OVER BIGH:SIZE @ ALLOC:BIGH - ALLOC:SMALLH - OVER ALLOC:SIZE !
    DUP ALLOC:USED 0 SWAP !
    DUP ALLOC:PREV 0 SWAP !
    ALLOC:NEXT 0 SWAP !
    DROP
;

: MERGE-RIGHT
    \ [block] [empty] -> [block+empty]
    DUP ALLOC:NEXT @ ALLOC:SIZE @ ALLOC:SMALLH + OVER ALLOC:SIZE +!
    DUP ALLOC:NEXT @ ALLOC:NEXT @ OVER ALLOC:NEXT !
    DUP ALLOC:NEXT @ ?DUP IF ALLOC:PREV ! ELSE DROP THEN
;

: MERGE-LEFT
    \ [empty] [block] -> [empty+block]
    ALLOC:PREV @ MERGE-RIGHT
;

: DALIGNED
    1 CELLS 1- 0 D+
    -1 AND SWAP -1 CELLS AND SWAP
;

ALSO FORTH DEFINITIONS

: ALLOCATE ( u -- a-addr ior )
    \ DEBUG-MEMORY-ALLOCATION
    \ HEX
    \ DUP 0 DALIGNED U. U.
    \ DUP U. ." ALLOCATE" CR
    \ DECIMAL
    \ DUP U. ." ALLOCATE" CR
    ALLOCATION-AREA 0= IF DROP 0 -21 EXIT THEN
    DUP 0 DALIGNED NIP 0<> IF DROP 0 -21 EXIT THEN
    ALIGNED DUP >R
    ALLOCATION-AREA ALLOC:BIGH +
    FIND-FREE-AREA ?DUP IF
        R> SWAP SPLIT-ALLOCATE 0
    ELSE
        R> DROP 0 -21
    THEN
    \ OVER U. ." ALLOCATED" CR
;

: FREE ( a-addr -- ior )
    ?DUP 0= IF 0 EXIT THEN
    \ DUP U. ." FREE" CR
    ALLOCATION-AREA 0= IF DROP -21 EXIT THEN
    ALLOC:SMALLH - >R

    R@ ALLOC:USED 0 SWAP !

    R@ ALLOC:NEXT @ IF
        R@ ALLOC:NEXT @ ALLOC:USED @ IF 4 ELSE 0 THEN
    ELSE
        1
    THEN

    R@ ALLOC:PREV @ IF
        R@ ALLOC:PREV @ ALLOC:USED @ IF 8 ELSE 0 THEN
    ELSE
        2
    THEN

    OR CASE
        0 OF ( empty block empty ) R@ MERGE-RIGHT R> MERGE-LEFT ENDOF
        1 OF ( empty block end ) R> MERGE-LEFT ENDOF
        2 OF ( start block empty ) R> MERGE-RIGHT ENDOF
        3 OF ( start block end ) R> ALLOC:USED 0 SWAP ! ENDOF
        4 OF ( empty block used ) R> MERGE-LEFT ENDOF
        \ 5 OF ( impossible ) ENDOF
        6 OF ( start block used ) R> ALLOC:USED 0 SWAP ! ENDOF
        \ 7 OF ( impossible ) ENDOF
        8 OF ( used block empty ) R> MERGE-RIGHT ENDOF
        9 OF ( used block end ) R> ALLOC:USED 0 SWAP ! ENDOF
        \ 10 OF ( impossible ) ENDOF
        \ 11 OF ( impossible ) ENDOF
        12 OF ( used block used ) R> ALLOC:USED 0 SWAP ! ENDOF
        DUP ." UNKNOWN MEMORY-ALLOC STATE " U. CR
    ENDCASE
    0
;

: RESIZE ( a-addr u -- a-addr ior )
    \ 2DUP SWAP U. U. ." RESIZE" CR
    \ DEBUG-MEMORY-ALLOCATION
    ALLOCATION-AREA 0= IF DROP -21 EXIT THEN
    OVER FREE ?DUP IF NIP EXIT THEN
    DUP ALLOCATE ?DUP IF NIP NIP EXIT THEN
    ROT 2DUP = IF DROP NIP 0 EXIT THEN
    DUP >R SWAP ROT MOVE R> 0
;
