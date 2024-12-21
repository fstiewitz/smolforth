: CCOUNT-MAX
    >R
    DUP 0
    BEGIN
        OVER C@
        R@ 0 > AND
    WHILE
        1+ SWAP 1+ SWAP
        R> 1- >R
    REPEAT
    R> DROP
    NIP
;

: CCOUNT
    DUP 0
    BEGIN
        OVER C@
    WHILE
        1+ SWAP 1+ SWAP
    REPEAT
    NIP
;
