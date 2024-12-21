: 2CONSTANT CREATE , , DOES> 2@ ;

: 2LITERAL SWAP POSTPONE LITERAL POSTPONE LITERAL ; IMMEDIATE

: 2VARIABLE CREATE 2 CELLS ALLOT ;

: D0< SWAP DROP 0 < ;

: D0= 0 = SWAP 0 = AND ;

: D2*
    1 LSHIFT SWAP \ SH L
    DUP 0 < 1 AND \ SH L Lb
    ROT OR SWAP \ SH|Lb L
    1 LSHIFT SWAP \ LH SH|Lb
;

: D2/
    SWAP \ H L
    1 RSHIFT SWAP \ SL H
    DUP 1 AND IF 0 INVERT 1 RSHIFT INVERT ELSE 0 THEN \ SL H HbS
    ROT OR SWAP \ HbS|SL H
    2/ \ HbS|SL SH
;

: D<
    ROT SWAP \ x0 y0 x1 y1
    2DUP < IF
        2DROP 2DROP -1
    ELSE
        > IF
            2DROP 0
        ELSE
            U<
        THEN
    THEN
;

: D= ROT = >R = R> AND ;

[DEFINED] ASSEMBLER [IF]
CODE D>S
    *ENTER ]
    -1 *GROW
    [ *LEAVE
*END-CODE
[ELSE]
: D>S DROP ;
[THEN]


: DMAX
    2DUP >R >R 2OVER >R >R D< IF
        R> R> 2DROP R> R>
    ELSE
        R> R> R> R> 2DROP
    THEN
;

: DMIN
    2DUP >R >R 2OVER >R >R D< IF
        R> R> R> R> 2DROP
    ELSE
        R> R> 2DROP R> R>
    THEN
;

: DNEGATE 0 0 2SWAP D- ;

: DABS DUP 0< IF DNEGATE THEN ;

: M+ S>D D+ ;

: 2ROT >R >R 2SWAP R> R> 2SWAP ;

: 2VALUETO
    IF
        CELL+ 2!
    ELSE
        CELL+ 2@
    THEN
;

: 2VALUE CREATE ['] 2VALUETO , , , DOES> DUP 0 ROT @ EXECUTE ;

: DU<
    ROT SWAP
    2DUP U< IF
        2DROP 2DROP -1
    ELSE
        U> IF
            2DROP 0
        ELSE
            U<
        THEN
    THEN
;

: D. SWAP OVER DABS <# #S ROT SIGN #> TYPE SPACE ;

: D.R
    >R
    SWAP OVER DABS <# #S ROT SIGN #>
    DUP R> - DUP 0 < IF
        NEGATE SPACES
    ELSE
        DROP
    THEN
    TYPE SPACE
;
