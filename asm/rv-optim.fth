VOCABULARY OPTIM
[DEFINED] ADD-WORDLIST [IF] ' OPTIM >BODY ADD-WORDLIST [THEN]
ALSO OPTIM DEFINITIONS

DECIMAL

0 VALUE SIZE:DROP
0 VALUE SIZE:DUP
0 VALUE SIZE:SWAP
0 VALUE SIZE:ROT

0 VALUE ENABLED

HERE ' DROP COMPILE, HERE OVER - TO SIZE:DROP ORG
HERE ' DUP COMPILE, HERE OVER - TO SIZE:DUP ORG
HERE ' SWAP COMPILE, HERE OVER - TO SIZE:SWAP ORG
HERE ' ROT COMPILE, HERE OVER - TO SIZE:ROT ORG

.( \ DROP: ) SPACE SIZE:DROP . CR
.( \ DUP: ) SPACE SPACE SIZE:DUP . CR
.( \ SWAP: ) SPACE SIZE:SWAP . CR
.( \ ROT: ) SPACE SPACE SIZE:ROT . CR

: >ID&SIZE
    2DUP S" DROP" COMPARE 0= IF 2DROP 1 SIZE:DROP EXIT THEN
    2DUP S" DUP"  COMPARE 0= IF 2DROP 2 SIZE:DUP EXIT THEN
    2DUP S" SWAP" COMPARE 0= IF 2DROP 3 SIZE:SWAP EXIT THEN
    2DUP S" ROT"  COMPARE 0= IF 2DROP 4 SIZE:ROT EXIT THEN
    -1 ABORT" UNEXPECTED WORD PASSED TO OPTIMIZER"
;

VARIABLE START
VARIABLE EXP

\ OPTIMIZER

ALSO ASSEMBLER

15 CONSTANT USABLE-REGISTERS

CREATE SEQUENCE USABLE-REGISTERS CHARS ALLOT \ TODO calculate size better
CREATE USED USABLE-REGISTERS 2* CELLS ALLOT
VARIABLE SEQ-I
VARIABLE CSG

: RESET
    0 EXP !
    0 CSG !
    0 START !
    0 SEQ-I !
; RESET

: PUSH
    SEQ-I @ 16 = ABORT" UNEXPECTED OPTIMIZER STATE"
    SEQUENCE SEQ-I @ CHARS + C!
    1 SEQ-I +!
;

: GET-REGISTER
    DUP 0 8 WITHIN IF
        A0 +
    ELSE
        DUP 8 USABLE-REGISTERS WITHIN INVERT ABORT" INVALID REGISTER"
        8 - DUP 3 < IF
            T0 +
        ELSE
            3 - T3 +
        THEN
    THEN
;

: UO USABLE-REGISTERS 1- SWAP - 2* CELLS USED + ;

: CLEAR-USED
    USABLE-REGISTERS 0 DO
        I UO
        DUP I SWAP !
        CELL+ 99 SWAP !
    LOOP
;

: FETCH-REGISTER-OF ( i reg off -- )
    USABLE-REGISTERS 0 DO
        DUP I UO CELL+ @ = IF \ already stored in register
            2DROP
            UO I SWAP !
            UNLOOP
            EXIT
        THEN
    LOOP
    SWAP >R 2DUP SWAP UO CELL+ ! R> SWAP
    >R 2DUP DROP DUP UO ! R>
    *FETCH
    DROP
;

: STORE-REGISTER-OF ( i -- )
    DUP UO @ GET-REGISTER SWAP 1+ *STORE
;

VARIABLE OFF

: OPTIMIZE
    BASE @ >R
    DECIMAL
    START @ ORG
    DEPTH >R

    0 USABLE-REGISTERS 1- DO
        I
        -1
    +LOOP

    0 OFF !
    \ ." \ SEQ " SEQ-I @ . CR
    SEQ-I @ 0 DO
        SEQUENCE I CHARS + C@ CASE
            1 OF DROP -1 OFF +! ENDOF
            2 OF DUP 1 OFF +! ENDOF
            3 OF SWAP ENDOF
            4 OF ROT ENDOF
            -1 ABORT" UNEXPECTED WORD IN OPTIMIZER SEQUENCE"
        ENDCASE
    LOOP

    CLEAR-USED

    \ second pass: LX
    0 USABLE-REGISTERS 1- OFF @ + DO
        I PICK I OFF @ - <> IF
            \ ." \ LOAD " I . I GET-REGISTER . I PICK 1+ . CR
            I
            I GET-REGISTER
            I 2 + PICK 1+ FETCH-REGISTER-OF
        THEN
        -1
    +LOOP
    \ stack offset
    OFF @ ?DUP IF
        \ ." \ GROW " DUP . CR
        *GROW
    THEN
    \ third pass: SX
    0 USABLE-REGISTERS 1- OFF @ + DO
        I PICK I OFF @ - <> IF
            \ ." \ STORE " I . I GET-REGISTER . I 1+ . CR
            I STORE-REGISTER-OF
        THEN
        -1
    +LOOP

    HERE START @ - EXP !

    SEQ-I @ USABLE-REGISTERS = IF RESET THEN

    BEGIN
        DEPTH R@ >
    WHILE
        DROP
    REPEAT
    R> DROP
    R> BASE !
;

\ OPTIMIZER END

: QUEUE ( c-addr u -- )
    BASE @ >R
    HEX
    2DUP >ID&SIZE DUP >R EXP +!
    START @ 0= IF
        RESET
        STATE SYS:CSRI @ CSG !
        R> EXP !
        ( DUP ) PUSH
        HERE EXP @ - START !
        2DROP \ ." \ OPTIM 0-START " START @ . EXP @ . . TYPE CR
        OPTIMIZE
    ELSE
        STATE SYS:CSRI @ CSG @ =
        HERE START @ - EXP @ = AND IF
            R> DROP
            ( DUP ) PUSH
            2DROP \ ." \ OPTIM STEP " START @ . EXP @ . . TYPE CR
            OPTIMIZE
        ELSE
            RESET
            STATE SYS:CSRI @ CSG !
            R> EXP !
            ( DUP ) PUSH
            HERE EXP @ - START !
            2DROP \ ." \ OPTIM START " START @ . EXP @ . . TYPE CR
            OPTIMIZE
        THEN
    THEN
    R> BASE !
;

: RV_OPTIM
    ENABLED IF
        NAME>STRING QUEUE
    ELSE
        DROP
    THEN
    \ ." \ "
    \ HERE .
    \ ." QUOTE " NEXT-WORD NAME>STRING TYPE SPACE
    \ ." QUOTE " NAME>STRING TYPE SPACE ." OPTIMIZED-CALL" CR
; ' RV_OPTIM IS OPTIM-IMPL

-1 TO ENABLED

0 [IF]
: ABC
    80 . CR
    70 DUP . . CR
    70 80 90 DROP . . CR
    70 60 SWAP . . CR
    70 60 50 ROT . . . CR
    10 20 30 DROP
    SWAP DROP . CR
    90 . CR
    1 2
    1 IF
        SWAP
    THEN
    BEGIN
        SWAP
    1
    UNTIL
    . . CR
    0 @
; ABC
[THEN]

PREVIOUS

ALSO FORTH DEFINITIONS