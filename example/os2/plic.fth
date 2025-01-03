ONLY FORTH DEFINITIONS
VOCABULARY PLIC
ALSO PLIC DEFINITIONS

HEX
0C000000 CONSTANT PLIC:BASE
4 CONSTANT PLIC:PRIORITY-BASE
2000 CONSTANT PLIC:ENABLE-BASE
80 CONSTANT PLIC:ENABLE-STRIDE
200000 CONSTANT PLIC:CONTEXT-BASE
1000 CONSTANT PLIC:CONTEXT-STRIDE

0 CONSTANT PLIC:MACHINE

: PLIC:THRESHOLD ( hart mode -- w-addr )
    SWAP 2* + PLIC:CONTEXT-STRIDE *
    PLIC:BASE PLIC:CONTEXT-BASE + +
;

: PLIC:PRIORITY ( interrupt -- c-addr )
    PLIC:PRIORITY-BASE * PLIC:BASE +
;

: PLIC:MPLIC-CLAIM ( hart mode -- w-addr )
    PLIC:THRESHOLD 4 +
;

: PLIC:MPLIC-ENABLE ( hart mode -- w-addr )
    SWAP 2* + PLIC:ENABLE-STRIDE *
    PLIC:BASE PLIC:ENABLE-BASE + +
;

: PLIC:CLAIM ( id -- interrupt )
    PLIC:MACHINE PLIC:MPLIC-CLAIM W@
;

: PLIC:COMPLETE ( interrupt id -- )
    PLIC:MACHINE PLIC:MPLIC-CLAIM W!
;

: PLIC:ENABLE ( interrupt id -- )
    PLIC:MACHINE PLIC:MPLIC-ENABLE
    OVER 20 / 4 * + \ interrupt w-addr
    DUP W@ ROT 20 MOD 1 SWAP LSHIFT OR SWAP W!
;
