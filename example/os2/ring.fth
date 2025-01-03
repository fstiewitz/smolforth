ALSO FORTH DEFINITIONS
VOCABULARY RING
ALSO RING DEFINITIONS

BEGIN-STRUCTURE RING:HEADER
    FIELD: RING:RHEAD
    FIELD: RING:WHEAD
    FIELD: RING:SIZE
END-STRUCTURE

: RING:MEM RING:HEADER + ;

: RING:ALLOT ( size -- )
    1+ >R
    HERE
    RING:HEADER ALLOT
    DUP RING:RHEAD 0 SWAP !
    DUP RING:WHEAD 0 SWAP !
    R@ SWAP RING:SIZE !
    R> ALLOT
;

: RING:PUSH ( v ring -- )
    DUP >R RING:WHEAD @ 1+ R@ RING:SIZE @ MOD R@ RING:RHEAD @ = IF R> DROP DROP 0 EXIT THEN
    R@ RING:WHEAD @ R@ RING:MEM + C!
    R@ RING:WHEAD @ 1+ R@ RING:SIZE @ MOD R> RING:WHEAD !
    -1
;

: RING:POP ( ring -- v -1 | 0 )
    DUP >R RING:WHEAD @ R@ RING:RHEAD @ = IF R> DROP 0 EXIT THEN
    R@ RING:RHEAD @ R@ RING:MEM + C@
    R@ RING:RHEAD @ 1+ R@ RING:SIZE @ MOD R> RING:RHEAD !
    -1
;

: RING:EMPTY?
    DUP >R RING:WHEAD @ R> RING:RHEAD @ =
;

PREVIOUS
