: [ELSE]
    1 BEGIN
        BEGIN
            BL WORD COUNT
            DUP
        WHILE
            2DUP S" [IF]" COMPARE 0= IF
                2DROP 1+
            ELSE
                2DUP S" [ELSE]" COMPARE 0= IF
                    2DROP
                    1- DUP IF 1+ THEN
                ELSE
                    S" [THEN]" COMPARE 0= IF
                        1-
                    THEN
                THEN
            THEN ?DUP 0= IF EXIT THEN
        REPEAT 2DROP
        REFILL 0=
    UNTIL
    DROP
; IMMEDIATE

: [IF] 0= IF POSTPONE [ELSE] THEN ; IMMEDIATE
: [THEN] ; IMMEDIATE
