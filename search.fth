\ WL:LEN is a constant with the maximum number of lists in the search order

: WL:COUNT \ ( -- n ) count the number of lists in the search order
    CONTEXT
    WL:LEN 2 - 0 DO
        DUP I CELLS + @ 0= IF
            DROP I UNLOOP EXIT
        THEN
    LOOP
    DROP
    WL:LEN 2 -
;

: CURRENT CONTEXT WL:LEN 1- CELLS + ;
: GET-CURRENT CURRENT @ ;
: SET-CURRENT CURRENT ! ;
: DEFINITIONS CONTEXT @ CURRENT ! ;

: FORTH-WORDLIST ['] FORTH >BODY ;

: SET-ORDER
    DUP -1 = IF
        DROP
        FORTH-WORDLIST
        1
    THEN
    CONTEXT WL:LEN 2 - CELLS ERASE
    0 ?DO \ widn ... wid1
        CONTEXT I CELLS + !
    LOOP
;

: GET-ORDER
    WL:COUNT DUP >R 1- CELLS R@ 0 ?DO \ lcells R: l
        DUP I CELLS - CONTEXT + @ SWAP \ wid lcells ...
    LOOP
    DROP
    R>
;

: MAKE-WORDLIST
    0 , CURRENT @ @ , DOES> >R GET-ORDER NIP R> SWAP SET-ORDER
;

: VOCABULARY
    STATE SYS:WDATA @ ?DUP IF
        STATE SYS:ADATA DUP @ >R -1 >R !
        0 STATE SYS:WDATA !
    ELSE
        0 >R
    THEN
    CREATE MAKE-WORDLIST
    R> IF
        STATE SYS:ADATA @ STATE SYS:WDATA !
        R> STATE SYS:ADATA !
    THEN
;

: WORDLIST
    STATE SYS:WDATA @ ?DUP IF
        STATE SYS:ADATA DUP @ >R -1 >R !
        0 STATE SYS:WDATA !
    ELSE
        0 >R
    THEN
    S" UNNAMED" >CREATE CURRENT @ @ >BODY MAKE-WORDLIST
    R> IF
        STATE SYS:ADATA @ STATE SYS:WDATA !
        R> STATE SYS:ADATA !
    THEN
;

: NAME>STRING ( xt -- c-addr len )
    1-
    BEGIN
        1-
        DUP C@ 1 = INVERT
    UNTIL
    0 >R
    BEGIN
        DUP C@ 0= INVERT
    WHILE
        1-
        R> 1+ >R
    REPEAT
    1+ R>
;

: >LINK @ ;

: IMMEDIATE? 1- C@ 1 AND 0= INVERT ;

: ORDER
    CONTEXT
    WL:COUNT 0 DO
        DUP @ 2 CELLS - NAME>STRING TYPE CR
        CELL+
    LOOP
    DROP
    ." CURRENT " CURRENT @ 2 CELLS - NAME>STRING TYPE CR
;

: TRAVERSE-WORDLIST
    @
    BEGIN
        DUP 0= INVERT
    WHILE \ xt wid
        2DUP 2>R
        SWAP EXECUTE IF
            2R>
        ELSE
            2R> 2DROP
            EXIT
        THEN
        >LINK
    REPEAT
    2DROP
;

: TRAVERSE-SEARCH ( c-addr u 0 nt -- c-addr u 0 -1 | xt 1 0 | xt -1 0 )
    2OVER 2>R
    DUP NAME>STRING 2R> COMPARE 0= IF
        >R 2DROP DROP R>
        DUP IMMEDIATE? IF
            1
        ELSE
            -1
        THEN
        0
    ELSE
        DROP
        -1
    THEN
;

: SEARCH-WORDLIST
    0 SWAP ['] TRAVERSE-SEARCH SWAP
    TRAVERSE-WORDLIST ?DUP 0<> INVERT IF
        2DROP
        0
    THEN
;

: WORDS
    CONTEXT @ @
    BEGIN
        DUP 0= INVERT
    WHILE
        DUP -1 + C@ U.
        DUP NAME>STRING TYPE CR
        >LINK
    REPEAT
    DROP
;

: HIDE
    CONTEXT @ @
    DUP >LINK CONTEXT @ !
;

: REVEAL
    CONTEXT @ !
;

: ONLY
    CURRENT -1 CELLS + CONTEXT DO
        0 I !
        1 CELLS
    +LOOP
    FORTH
;

: ALSO ( -- )
    WL:COUNT DUP WL:LEN 2 - = IF
        ABORT" SEARCH ORDER FULL"
    THEN
    >R
    CONTEXT DUP CELL+ 2DUP R> CELLS MOVE
    @ SWAP !
;

: PREVIOUS ( -- )
    WL:COUNT DUP 1 = IF
        ABORT" SEARCH ORDER WOULD BECOME EMPTY"
    THEN
    CONTEXT DUP CELL+ SWAP ROT 1- CELLS DUP >R MOVE
    R> CONTEXT + 0 SWAP !
;

: MARKER
    HERE CREATE , DOES>
    @ DUP ORG
    CONTEXT
    WL:COUNT 0 DO
        SWAP >R
        DUP @ \ context wl
        DUP @
        BEGIN
            DUP R@ < INVERT
        WHILE
            >LINK
        REPEAT
        SWAP DUP ROT SWAP !
        DROP
        CELL+ R> SWAP
    LOOP
    2DROP
;
