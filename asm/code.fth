ONLY FORTH DEFINITIONS
ALSO ASSEMBLER

VARIABLE CURRENT-CODE

DECIMAL

: CODE
    CREATE
    CURRENT @ @
    DUP CURRENT-CODE !
    DUP 1 - DUP C@ -64 AND 32 OR SWAP C!
    CELL+ 0 SWAP !
    ALSO ASSEMBLER
;

: ;CODE
    CURRENT-CODE @
    CELL+ HERE SWAP !
;

: *END-CODE
    HERE CURRENT-CODE @ DUP EXECUTE
    CELL+ !
    *RET
    PREVIOUS
;

: ;END-CODE
    HERE
    *ENTER
    CURRENT-CODE @ DUP EXECUTE
    CELL+ !
    *LEAVE
    PREVIOUS
;

: END-CODE
    PREVIOUS
;

ONLY FORTH DEFINITIONS
