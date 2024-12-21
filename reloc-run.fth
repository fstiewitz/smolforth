ONLY FORTH DEFINITIONS
DECIMAL

: GET-INCLUDE-NAME
    S" ARGV" ENVIRONMENT? IF
        DUP 1 > IF
            0 0 ROT
            BEGIN
                DUP 1 >
            WHILE
                >R 2>R
                2DUP S" -c" COMPARE 0= IF
                    2R> 2DROP 2OVER 2>R
                THEN
                2DROP
                2R> R>
                1-
            REPEAT
            DROP
            2SWAP 2DROP
            ?DUP IF
                EXIT
            ELSE
                DROP
            THEN
        ELSE
            0 ?DO 2DROP LOOP
        THEN
    THEN
    S" boot.fth"
;

STATE SYS:ADATA @ ADD-SECTION
STATE SYS:CDATA @ ADD-SECTION
STATE SYS:IDATA @ ADD-SECTION
STATE SYS:UDATA @ ADD-SECTION
STATE SYS:UIDATA @ ADD-SECTION
STATE SYS:ICDATA @ ADD-SECTION


: FIX-SECTIONS
    SECTION-COUNT @ 0 ?DO
        SECTIONS @ I 4 * CELLS +
        DUP @ DATA:HERE @
        SWAP CELL+ !
    LOOP
;

: FIX-ENDS
    SECTION-COUNT @ 0 ?DO
        SECTIONS @ I 4 * CELLS +
        DUP @ DATA:HERE @
        SWAP 2 CELLS + !
    LOOP
;

: PRINT-NAME
    ?DUP IF
        DUP NAME>STRING ?DUP IF
            ROT . ." QUOTE "
            TYPE
        ELSE
            1 THROW
        THEN
    ELSE
        1 THROW
    THEN
    SPACE
;

: PRINT-NAME-BODY
    ?DUP IF
        DUP NAME>STRING ?DUP IF
            ROT . ." QUOTE body$"
            TYPE
        ELSE
            1 THROW
        THEN
    ELSE
        1 THROW
    THEN
    SPACE
;

: IN-BODY? ( xt addr -- flag )
    SWAP DUP >BODY WITHIN INVERT
;

: PRINT-NAME-OR-BODY ( xt addr -- "off name" )
    OVER IF
        2DUP IN-BODY? IF
            2DUP SWAP >BODY - .
            DROP DUP NAME>STRING ?DUP IF
                ROT . ." QUOTE body$"
                TYPE
            ELSE 1 THROW THEN
        ELSE
            2DUP SWAP - .
            DROP DUP NAME>STRING ?DUP IF
                ROT . ." QUOTE "
                TYPE
            ELSE
                2 THROW
            THEN
        THEN
    ELSE
        3 THROW
    THEN
    SPACE
;

: PRINT-NAME-OR-BODY-OR-DOES ( xt addr -- "off name" )
    OVER IF
        2DUP IN-BODY? IF
            2DUP SWAP >BODY - 0 = IF
                2DUP SWAP >BODY - .
                DROP DUP NAME>STRING ?DUP IF
                    ROT . ." QUOTE body$"
                    TYPE
                ELSE 1 THROW THEN
            ELSE
                DROP DUP NAME>STRING ?DUP IF
                    ." 0 "
                    ROT .
                    ." QUOTE does$" TYPE
                ELSE 1 THROW THEN
            THEN
        ELSE
            2DUP SWAP - .
            DROP DUP NAME>STRING ?DUP IF
                ROT . ." QUOTE "
                TYPE
            ELSE
                2 THROW
            THEN
        THEN
    ELSE
        3 THROW
    THEN
    SPACE
;

: RELOC-FIND
    DUP >R
    0
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @ @
        BEGIN
            DUP 0= INVERT
        WHILE \ -- x best candidate --
            2 PICK OVER U< INVERT IF \ x >= candidate
                2 PICK OVER - >R \ x - candidate
                OVER 3 PICK SWAP - \ x - best
                R> > IF \ db > dc
                    NIP DUP
                THEN
            THEN
            >LINK
        REPEAT
        DROP
    LOOP
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @ @
        BEGIN
            DUP 0= INVERT
        WHILE \ -- x best candidate --
            2 PICK OVER >BODY U< INVERT IF \ x >= candidate
                2 PICK OVER >BODY - >R \ x - candidate
                OVER 3 PICK SWAP - \ x - best
                R> > IF \ db > dc
                    NIP DUP
                THEN
            THEN
            >LINK
        REPEAT
        DROP
    LOOP
    NIP
    ?DUP IF
        R> DROP
        -1
    ELSE
        R> DROP
        0
    THEN
;

: RELOC-WORDLISTS
    ONLY FORTH DEFINITIONS
    ['] FORTH >BODY ADD-WORDLIST
    S" ' SUBST >BODY ADD-WORDLIST" EVALUATE
    S" [DEFINED] ASSEMBLER [IF] ' ASSEMBLER >BODY ADD-WORDLIST [THEN]" EVALUATE
    BASE @ >R
    HEX
    R:COUNT @ 0 DO
        ." \ " R:CONTEXT @ I CELLS + @ DUP . CELL+ DUP . @ DUP . NAME>STRING ." WORDLIST " TYPE CR
    LOOP
    R> BASE !
;

0 VALUE RELOC-START
0 VALUE RELOC-END
0 VALUE SECTION-NAME-PTR
0 VALUE SECTION-NAME-SIZE
0 VALUE DEFER-IMPL
0 VALUE VALUE-IMPL

: PRINT-NAME
    ?DUP IF
        DUP NAME>STRING ?DUP IF
            ROT . ." QUOTE "
            TYPE
        ELSE
            1 THROW
        THEN
    ELSE
        1 THROW
    THEN
    SPACE
;

: RELOC-RESOLVE
    DUP >R
    RELOC-FIND IF
        DUP R> SWAP - .
        DUP .
        ." QUOTE "
        NAME>STRING TYPE
        SPACE
        ." RELOC"
    ELSE
        R> DROP
        ." 0 0 RELOC"
    THEN
    CR
;

: RELOC-RESOLVE-DOES
    RELOC-FIND IF
        ." 0 "
        DUP .
        ." QUOTE does$"
        NAME>STRING TYPE
        SPACE
        ." RELOC" CR
    ELSE
        ." 0 0 0 RELOC" CR
    THEN
;

: IN-ANY-SECTION?
    SECTION-COUNT @ 0 ?DO
        DUP
        SECTIONS @ I 4 * CELLS + CELL+ @
        SECTIONS @ I 4 * CELLS + 2 CELLS + @
        WITHIN IF
            DROP
            UNLOOP
            -1
            EXIT
        THEN
    LOOP
    DROP
    0
;

: RELOC-EXPORT
    BASE @ >R HEX

    SECTION-NAME-PTR SECTION-NAME-SIZE W/O CREATE-FILE THROW >R
    RELOC-START DUP RELOC-END SWAP - R@ WRITE-FILE THROW
    R> CLOSE-FILE THROW

    RELOC-START . RELOC-END . ." LIMIT" CR
    ." \ " RELOC-START RELOC-END SWAP - . CR
    \ first pass: relocations of word definitions
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @ @ DUP
        BEGIN
            DUP 0= INVERT
        WHILE
            DUP RELOC-START RELOC-END WITHIN IF
                DUP >R
                R@ @ IN-ANY-SECTION? INVERT IF
                    ." ( " R@ NAME>STRING TYPE SPACE ." ) "
                    R@ DUP . @ DUP . RELOC-RESOLVE \ link
                ELSE
                    ." ( " R@ NAME>STRING TYPE SPACE ." ) LOCAL "
                    R@ DUP . @ DUP . RELOC-RESOLVE \ link
                THEN
                R@ 1- C@ 16 AND IF
                    R@ CELL+ @ DEFER-IMPL =
                    R@ CELL+ @ VALUE-IMPL = OR IF
                        R@ CELL+ @ IN-ANY-SECTION? INVERT IF
                            ." ( " R@ NAME>STRING TYPE SPACE ." ) "
                            R@ CELL+ DUP . @ DUP . RELOC-RESOLVE
                        ELSE
                            ." ( " R@ NAME>STRING TYPE SPACE ." ) LOCAL "
                            R@ CELL+ DUP . @ DUP . RELOC-RESOLVE
                        THEN
                        R@ 2 CELLS + @ IN-ANY-SECTION? INVERT IF
                            ." ( " R@ NAME>STRING TYPE SPACE ." ) "
                            R@ 2 CELLS + DUP . @ DUP . RELOC-RESOLVE
                        ELSE
                            ." ( " R@ NAME>STRING TYPE SPACE ." ) LOCAL "
                            R@ 2 CELLS + DUP . @ DUP . RELOC-RESOLVE
                        THEN
                    ELSE
                        R@ CELL+ @ IF
                            R@ CELL+ @ IN-ANY-SECTION? INVERT IF
                                ." ( " R@ NAME>STRING TYPE SPACE ." ) "
                                R@ CELL+ DUP . @ DUP . RELOC-RESOLVE-DOES
                            ELSE
                                ." ( " R@ NAME>STRING TYPE SPACE ." ) LOCAL "
                                R@ CELL+ DUP . @ DUP . RELOC-RESOLVE-DOES
                            THEN
                        THEN
                    THEN
                THEN
                R@ 1- C@ 32 AND IF
                    R@ CELL+ @ IN-ANY-SECTION? INVERT IF
                        ." ( " R@ NAME>STRING TYPE SPACE ." ) "
                        R@ CELL+ DUP . @ DUP . RELOC-RESOLVE
                    ELSE
                        ." ( " R@ NAME>STRING TYPE SPACE ." ) LOCAL "
                        R@ CELL+ DUP . @ DUP . RELOC-RESOLVE
                    THEN
                THEN
                R>
            THEN
            >LINK
        REPEAT
        2DROP
        R:CONTEXT @ I CELLS + @ DUP . @ DUP . RELOC-RESOLVE
    LOOP
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @ CELL+ DUP . @ DUP . RELOC-RESOLVE
    LOOP
    \ second pass: symbols
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @ DUP @
        0 >R
        BEGIN
            DUP 0= INVERT
        WHILE
            DUP RELOC-START RELOC-END WITHIN IF
                R@ INVERT IF
                    DUP ." QUOTE " NAME>STRING TYPE SPACE ." WL-END" CR
                THEN
                R> DROP -1 >R
                ." LOCAL "
                DUP .
                DUP ['] PRINT-NAME CATCH IF
                    DROP
                    ." QUOTE UNKNOWN "
                THEN
                ." SYMBOL" CR
            THEN
            DUP >BODY RELOC-START RELOC-END WITHIN IF
                R> DROP -1 >R
                ." LOCAL "
                DUP >BODY .
                DUP ['] PRINT-NAME-BODY CATCH IF
                    DROP
                    ." QUOTE UNKNOWN "
                THEN
                ." SYMBOL" CR
            THEN
            >LINK
        REPEAT
        DROP
        ?DUP R> AND IF
            CELL+ @ ['] PRINT-NAME CATCH IF
                DROP
            ELSE
                ." WORDLIST" CR
            THEN
        THEN
    LOOP
    R> BASE !
;

: FIX-LINKS
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @
        DUP ['] FORTH >BODY = IF
            BEGIN
                DUP 0= INVERT
            WHILE
                DUP IN-ANY-SECTION? IF
                    DUP >LINK IN-ANY-SECTION? INVERT IF
                        DUP SAVE-CORE SWAP !
                    THEN
                THEN
                >LINK
            REPEAT
            DROP
        ELSE
            DROP
        THEN
    LOOP
;

: DO-RELOC
    RELOC-WORDLISTS
    \ first pass: symbols to wordlists
    HEX
    R:COUNT @ 0 DO
        R:CONTEXT @ I CELLS + @ DUP DUP . @
        ." WL-ASSOC:START" CR
        BEGIN
            DUP 0= INVERT
        WHILE
            DUP .
            DUP ['] PRINT-NAME CATCH IF
                    DROP
                    ." QUOTE UNKNOWN "
            THEN
            ." WL-ASSOC:SYMBOL" CR
            DUP >BODY .
            DUP ['] PRINT-NAME-BODY CATCH IF
                DROP
                ." QUOTE UNKNOWN "
            THEN
            ." WL-ASSOC:SYMBOL" CR
            >LINK
        REPEAT
        DROP
        DUP .
        ?DUP IF
            CELL+ @ ['] PRINT-NAME CATCH IF
                DROP
                ." 0 0 WL-ASSOC:WORDLIST" CR
            ELSE
                ." WL-ASSOC:WORDLIST" CR
            THEN
        ELSE
            . ." 0 0 WL-ASSOC:WORDLIST" CR
        THEN
    LOOP
    DECIMAL
    FIX-LINKS
    SECTION-COUNT @ 0 ?DO
        SECTIONS @ I 4 * CELLS + @ DATA:WORD @ ?DUP IF
            ." QUOTE "
            NAME>STRING 2DUP TYPE SPACE
            S" section" REPLACES
        ELSE
            ." QUOTE SYS.CODE "
            S" SYS.CODE" S" section" REPLACES
        THEN
        SECTIONS @ I 4 * CELLS + 3 CELLS + @ .
        ." SECTION" CR
        SECTIONS @ I 4 * CELLS + CELL+ @ TO RELOC-START
        SECTIONS @ I 4 * CELLS + 2 CELLS + @ TO RELOC-END
        SECTIONS @ I 4 * CELLS + 3 CELLS + @ 0 <# #S #> S" flags" REPLACES
        S" out.%section%.%flags%.bin" PAD 84 SUBSTITUTE 0 < IF
            1 THROW
        THEN
        TO SECTION-NAME-SIZE
        TO SECTION-NAME-PTR
        0 ['] SUBST >BODY !
        RELOC-EXPORT
    LOOP
;

: VOCABULARY
    VOCABULARY
    CURRENT @ @ >BODY ADD-WORDLIST
;

: DOES>
    POSTPONE DOES>
    BASE @ >R
    HEX
    NEXT-WORD IF
        NEXT-WORD NAME>STRING ?DUP IF
        \ TODO 12 is an architecture-specific constant
            COMPILER-STATUS @ . NEXT-WORD . ." QUOTE does$" TYPE SPACE ." SYMBOL" CR
        ELSE
            DROP
        THEN
    THEN
    R> BASE !
; IMMEDIATE

: RELOC-COMPILE-CONSTANT
    BASE @ >R
    HEX
    2DUP
    STATE SYS:CDATA @ DATA:HERE @ .
    U.
    ['] PRINT-NAME CATCH IF
        DROP
        0 .
    THEN
    ." RELOC-CONSTANT" CR
    R> BASE !
    DEFERS COMPILE-CONSTANT
;

: RELOC-COMPILE-ADDR
    BASE @ >R
    HEX
    DUP IN-ANY-SECTION? IF ." LOCAL " THEN
    STATE SYS:CDATA @ DATA:HERE @ .
    2DUP PRINT-NAME-OR-BODY
    DEFERS COMPILE-ADDR
    COMPILER-STATUS @ .
    ." RELOC-ADDR" CR
    R> BASE !
;

: RELOC-COMPILE-EXECUTE
    BASE @ >R
    HEX
    DUP IN-ANY-SECTION? IF ." LOCAL " THEN
    STATE SYS:CDATA @ DATA:HERE @ .
    OVER IF
        OVER 1 - C@ 16 AND IF
            2DUP 2>R
            NIP RELOC-FIND IF
                2R> NIP
            ELSE
                2R>
            THEN
        THEN
    THEN
    2DUP PRINT-NAME-OR-BODY-OR-DOES
    DEFERS COMPILE-EXECUTE
    COMPILER-STATUS @ .
    ." RELOC-EXECUTE" CR
    R> BASE !
;

' RELOC-COMPILE-ADDR IS COMPILE-ADDR
' RELOC-COMPILE-CONSTANT IS COMPILE-CONSTANT
' RELOC-COMPILE-EXECUTE IS COMPILE-EXECUTE

ALIGN

STATE SYS:ADATA @ DATA:HERE @ STATE SYS:ADATA @ DATA:GATE !
STATE SYS:CDATA @ DATA:HERE @ STATE SYS:CDATA @ DATA:GATE !
STATE SYS:IDATA @ DATA:HERE @ STATE SYS:IDATA @ DATA:GATE !
STATE SYS:UDATA @ DATA:HERE @ STATE SYS:UDATA @ DATA:GATE !
STATE SYS:UIDATA @ DATA:HERE @ STATE SYS:UIDATA @ DATA:GATE !
STATE SYS:ICDATA @ DATA:HERE @ STATE SYS:ICDATA @ DATA:GATE !

.( \ RELOCATING ) GET-INCLUDE-NAME TYPE CR

RELOC-WORDLISTS

FIX-SECTIONS

GET-INCLUDE-NAME INCLUDED0

FIX-ENDS

DEFER DEFER-TEST
' DEFER-TEST CELL+ @ TO DEFER-IMPL

0 VALUE VALUE-TEST
' VALUE-TEST CELL+ @ TO VALUE-IMPL

DO-RELOC

