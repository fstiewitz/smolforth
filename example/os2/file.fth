ONLY FORTH DEFINITIONS
VOCABULARY FILE
ALSO FILE DEFINITIONS
DECIMAL

BEGIN-STRUCTURE FILE-DESCRIPTOR
    FIELD: FILE:READ
    FIELD: FILE:WRITE
    FIELD: FILE:CLOSE
    FIELD: FILE:POSITION
    FIELD: FILE:SIZE
    FIELD: FILE:REPOSITION
END-STRUCTURE

ALSO FORTH DEFINITIONS

: R/W 6 ;
: R/O 4 ;
: W/O 2 ;
: BIN 1 OR ;

: OPEN-FILE
    DROP
    ERR-SIZE !
    ERR-STRING !
    -38
;
: CLOSE-FILE 1 LSHIFT DUP FILE:CLOSE @ EXECUTE ;
: READ-FILE 1 LSHIFT DUP FILE:READ @ EXECUTE ;
: WRITE-FILE 1 LSHIFT DUP FILE:WRITE @ EXECUTE ;
: FILE-POSITION 1 LSHIFT DUP FILE:POSITION @ EXECUTE ;
: FILE-SIZE 1 LSHIFT DUP FILE:SIZE @ EXECUTE ;
: FILE-REPOSITION 1 LSHIFT DUP FILE:REPOSITION @ EXECUTE ;

: READ-LINE
    OVER 0 > INVERT IF 2DROP DROP 0 -1 0 EXIT THEN
    0
    BEGIN \ c-addr u fileid l
        2 PICK 0 >
    WHILE
        SP@ DUP 1 \ c-addr u fileid l &x &x 1
        4 PICK READ-FILE ?DUP IF
            >R 2DROP 2DROP DROP 0 0 R> EXIT
        THEN
        \ c-addr u fileid l c (1|0)
        IF
            255 AND
            DUP 13 = IF \ c-addr u fileid l c
                DROP SP@ 1 3 PICK READ-FILE 2DROP
                >R
                2DROP DROP R> -1 0 EXIT
            THEN
            DUP 10 = IF
                DROP NIP NIP NIP -1 0 EXIT
            THEN
            4 PICK C! \ c-addr u fileid l
            1+ ROT 1- ROT ROT \ c-addr u fileid l
            2>R >R 1+ R> 2R>
        ELSE
            DROP ?DUP IF
                >R 2DROP DROP R> -1 0 EXIT
            ELSE
                2DROP DROP 0 0 0 EXIT
            THEN
        THEN
    REPEAT
    NIP NIP NIP -1 0
;

: REFILL
    SOURCE-ID 0 > INVERT IF
        REFILL
    ELSE
        LINE-BUFFER 256
        SOURCE-ID
        READ-LINE IF 2DROP 0 EXIT THEN
        INVERT IF DROP 0 EXIT THEN
        LINE-SIZE !
        LINE-BUFFER LINE-PTR !
        0 PAO !
        -1
    THEN
;
