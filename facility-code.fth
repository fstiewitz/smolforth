: BEGIN-STRUCTURE CREATE STATE 14 CELLS + @ 2 CELLS + @ 0 0 , DOES> @ ;
: END-STRUCTURE SWAP ! ;
: +FIELD CREATE OVER , + DOES> @ + ;
: FIELD: ALIGNED 1 CELLS +FIELD ;
: CFIELD: 1 CHARS +FIELD ;
