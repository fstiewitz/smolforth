: SYS:LOOP
    R>
    R> R> \ sra final initial
    1+
    2DUP = IF
        2DROP
        -1
    ELSE
        >R >R
        0
    THEN
    SWAP >R
;

: SYS:+LOOP
    R> SWAP
    R> R> ROT >R \ sra f init
    R@ OVER + \ sra f old init
    >R OVER - R> \ sra f old init
    OVER DUP R@ + XOR >R \ o ^ (o + inc)
    OVER R> R@ SWAP >R XOR R> AND 0< IF \ o ^ inc
        R> 2DROP 2DROP
        -1
    ELSE
        R> DROP
        >R DROP >R
        0
    THEN
    SWAP >R
;

: I
    R> R> R> \ sra final initial
    DUP ROT SWAP >R >R SWAP >R
;

: J
    R> R> R> R> R> \ sra finali initiali finalo initialo
    DUP ROT SWAP >R >R \ sra finali initiali intialo
    ROT ROT >R >R SWAP >R
;
