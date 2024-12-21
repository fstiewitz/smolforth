DECIMAL
: EKEY>CHAR
    DUP 32 127 WITHIN
;

CREATE KEY-EVENT 2 ALLOT 0 KEY-EVENT C!

: CHECK-INT
    3 = IF
        ABORT" Interrupted"
    THEN
;

: KEY?
    BEGIN
        EKEY?
    WHILE
        EKEY EKEY>CHAR IF
            KEY-EVENT CHAR+ C!
            TRUE KEY-EVENT C!
            TRUE
            EXIT
        THEN
        CHECK-INT
    REPEAT
    0
;

: KEY
    KEY-EVENT C@ IF
        0 KEY-EVENT C!
        KEY-EVENT CHAR+ C@
    ELSE
        BEGIN
            EKEY EKEY>CHAR INVERT IF
                CHECK-INT
                0
            ELSE
                TRUE
            THEN
        UNTIL
    THEN
;

: ESC 27 EMIT ;

: CSI ESC [CHAR] [ EMIT ;

: AT-XY
    CSI
    0 <# #S #> TYPE
    [CHAR] ; EMIT
    0 <# #S #> TYPE
    [CHAR] H EMIT
;

: PAGE
    CSI
    [CHAR] 2 EMIT
    [CHAR] J EMIT
    0 0 AT-XY
;
