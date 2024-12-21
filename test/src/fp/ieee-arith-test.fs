(         TITLE:  IEEE SPECIAL DATA ARITHMETIC TESTS
           FILE:  IEEE-ARITH~TEST.FS
         AUTHOR:  DAVID N. WILLIAMS
        VERSION:  0.5.2
        LICENSE:  PUBLIC DOMAIN
  LAST REVISION:  OCTOBER 2, 2009

THE LAST REVISION DATE MAY REFLECT COSMETIC CHANGES NOT LOGGED
BELOW.

VERSION 0.5.2
 2OCT09 * MADE COMPILATION CONDITIONAL FOR +INF, -INF, +NAN,
          -NAN.

VERSION 0.5.1
11JUL09 * FIXED TESTS WITH TWO NAN INPUTS SO THE OUTPUT CAN BE
          EITHER OF THE TWO, AS ALLOWED BY IEEE.  SOLUTION
          SUGGESTED BY MARCEL HENDRIX.

VERSION 0.5.0
29JUN09 * STARTED
 1JUL09 * MOSTLY FINISHED.
 8JUL09 * ADDED FNAN? FOR FSQRT NANS.
)

CR .( RUNNING IEEE-ARITH-TEST.FS)
CR .( --------------------------) CR

\ FOR PFE:
\ LOADM IEEEFP
S" FLOATING-EXT" ENVIRONMENT? [IF] DROP [THEN]

\ S" TTESTER.FS" INCLUDED
DECIMAL
TRUE VERBOSE !

: ?.CR  ( -- )  VERBOSE @ IF CR THEN ;
?.CR

\ THE TTESTER DEFAULT FOR EXACT? IS TRUE.  UNCOMMENT THE
\ FOLLOWING LINE IF YOUR SYSTEM NEEDS IT TO BE FALSE:
\ SET-NEAR

VARIABLE #ERRORS  0 #ERRORS !

:NONAME  ( C-ADDR U -- )
(
DISPLAY AN ERROR MESSAGE FOLLOWED BY THE LINE THAT HAD THE
ERROR.
)
  1 #ERRORS +! ERROR1 ; ERROR-XT !

: ?.ERRORS  ( -- )  VERBOSE @ IF ." #ERRORS: " #ERRORS @ . THEN ;

[UNDEFINED] \\ [IF]  \ FOR DEBUGGING
: \\  ( -- )  -1 PARSE 2DROP BEGIN REFILL 0= UNTIL ; [THEN]

\ FABS SHOULD BE SUPERFLUOUS IN THESE:

0E FABS       FCONSTANT +0
+0 FNEGATE    FCONSTANT -0

[UNDEFINED] +INF [IF]
  1E 0E F/ FABS FCONSTANT +INF
  +INF FNEGATE  FCONSTANT -INF
[THEN]

[UNDEFINED] +NAN [IF]
\ FABS IS NOT SUPERFLOUS HERE, BECAUSE THE SIGN OF 0/0 IS NOT
\ SPECIFIED BY IEEE, AND IS ACTUALLY DIFFERENT IN MAC OS X
\ PPC/INTEL (+/-), BOTH FOR GFORTH AND PFE.  NOTE THAT IEEE-2008
\ DOES NOT REQUIRE THAT 0/0 BE A NAN WITH ZERO LOAD:
  0E 0E F/ FABS FCONSTANT +NAN
  +NAN FNEGATE  FCONSTANT -NAN
[THEN]

\ THE FOLLOWING HUGE KLUDGE IS JUST FOR TESTING SQRT(-1)!
\ BUT MAYBE FNAN? CAN ALSO BE USED TO IMPROVE SOME OF THE OTHER
\ TESTS.
[UNDEFINED] FNAN? [IF]
  : FDATUM=  ( F: R1 R2 -- S: FLAG )  0E F~ ;

  \ MAYBE THIS CAN BE IMPROVED
  : FNAN?  ( F: R -- S: ISNAN? )
    FDUP +0 FDATUM=
    FDUP -0 FDATUM= OR
    FDUP -INF FDATUM= OR
    FDUP +INF FDATUM= OR IF FDROP FALSE EXIT THEN
    +INF F< 0= ;
    
  \ BORROWED FROM IEEE-FPROX-TEST.FS
  T{ +0 +0     FDATUM= -> TRUE }T
  T{ +0 -0     FDATUM= -> FALSE }T
  T{ -0 +0     FDATUM= -> FALSE }T
  T{ -0 -0     FDATUM= -> TRUE }T
  T{  7E -2E   FDATUM= -> FALSE }T
  T{ -2E  7E   FDATUM= -> FALSE }T
  T{  7E  7E   FDATUM= -> TRUE }T
  T{  7E +INF  FDATUM= -> FALSE }T
  T{ +INF 7E   FDATUM= -> FALSE }T
  T{  7E -INF  FDATUM= -> FALSE }T
  T{ -INF 7E   FDATUM= -> FALSE }T
  T{ +INF +INF FDATUM= -> TRUE }T
  T{ +INF -INF FDATUM= -> FALSE }T
  T{ -INF +INF FDATUM= -> FALSE }T
  T{ -INF -INF FDATUM= -> TRUE }T
  T{ +NAN 7E   FDATUM= -> FALSE }T
  T{ -NAN 7E   FDATUM= -> FALSE }T
  T{  7E +NAN  FDATUM= -> FALSE }T
  T{  7E -NAN  FDATUM= -> FALSE }T
  T{ +NAN +NAN FDATUM= -> TRUE }T
  T{ -NAN +NAN FDATUM= -> FALSE }T
  T{ +NAN -NAN FDATUM= -> FALSE }T
  T{ -NAN -NAN FDATUM= -> TRUE }T
  T{ +INF +NAN FDATUM= -> FALSE }T
  T{ -INF +NAN FDATUM= -> FALSE }T
  T{ +INF -NAN FDATUM= -> FALSE }T
  T{ -INF -NAN FDATUM= -> FALSE }T
  T{ +NAN +INF FDATUM= -> FALSE }T
  T{ -NAN +INF FDATUM= -> FALSE }T
  T{ +NAN -INF FDATUM= -> FALSE }T
  T{ -NAN -INF FDATUM= -> FALSE }T
  T{ 1E +INF F< -> TRUE }T
  T{ +0   FNAN? -> FALSE }T
  T{ -0   FNAN? -> FALSE }T
  T{ +INF FNAN? -> FALSE }T
  T{ -INF FNAN? -> FALSE }T
  T{  1E  FNAN? -> FALSE }T
  T{ +NAN FNAN? -> TRUE }T
  T{ -NAN FNAN? -> TRUE }T
  #ERRORS @ 0=

\ NOTE THAT THE ABOVE IS NOT AIRTIGHT.  WE REALLY NEED TO KNOW
\ THAT THE IEEE SPECIAL DATA ARE CORRECT.

[ELSE] TRUE [THEN]
CONSTANT VALID-FNAN?-DEFINED

TESTING F+

\ IEEE-2008 6.3

T{ +0 +0 F+ -> +0 }T
T{ +0 -0 F+ -> +0 }T
T{ -0 +0 F+ -> +0 }T
T{ -0 -0 F+ -> -0 }T

T{ +NAN  2E  F+ -> +NAN }T
T{ -NAN  2E  F+ -> -NAN }T
T{  3E  +NAN F+ -> +NAN }T
T{  3E  -NAN F+ -> -NAN }T

T{ +NAN +NAN F+ -> +NAN }T
T{ -NAN +NAN F+ FABS -> +NAN }T
T{ +NAN -NAN F+ FABS -> +NAN }T
T{ -NAN -NAN F+ -> -NAN }T

T{  2E  +INF F+ -> +INF }T
T{ +INF  7E  F+ -> +INF }T
T{  2E  -INF F+ -> -INF }T
T{ -INF  7E  F+ -> -INF }T

T{ +NAN +INF F+ -> +NAN }T
T{ +INF +NAN F+ -> +NAN }T
T{ +NAN -INF F+ -> +NAN }T
T{ -INF +NAN F+ -> +NAN }T
T{ -NAN +INF F+ -> -NAN }T
T{ +INF -NAN F+ -> -NAN }T
T{ -NAN -INF F+ -> -NAN }T
T{ -INF -NAN F+ -> -NAN }T

T{ +INF +INF F+      -> +INF }T
T{ +INF -INF F+ FABS -> +NAN }T
T{ -INF +INF F+ FABS -> +NAN }T
T{ -INF -INF F+      -> -INF }T

TESTING F-

T{ +0 +0 F- -> +0 }T
T{ +0 -0 F- -> +0 }T
T{ -0 +0 F- -> -0 }T
T{ -0 -0 F- -> +0 }T

T{ +NAN  2E  F- -> +NAN }T
T{ -NAN  2E  F- -> -NAN }T
T{  3E  +NAN F- -> +NAN }T
T{  3E  -NAN F- -> -NAN }T

T{ +NAN +NAN F-      -> +NAN }T
T{ -NAN +NAN F- FABS -> +NAN }T
T{ +NAN -NAN F- FABS -> +NAN }T
T{ -NAN -NAN F-      -> -NAN }T

T{  2E  +INF F- -> -INF }T
T{ +INF  7E  F- -> +INF }T
T{  2E  -INF F- -> +INF }T
T{ -INF  7E  F- -> -INF }T

T{ +NAN +INF F- -> +NAN }T
T{ +INF +NAN F- -> +NAN }T
T{ +NAN -INF F- -> +NAN }T
T{ -INF +NAN F- -> +NAN }T
T{ -NAN +INF F- -> -NAN }T
T{ +INF -NAN F- -> -NAN }T
T{ -NAN -INF F- -> -NAN }T
T{ -INF -NAN F- -> -NAN }T

T{ +INF +INF F- FABS -> +NAN }T
T{ +INF -INF F-      -> +INF }T
T{ -INF +INF F-      -> -INF }T
T{ -INF -INF F- FABS -> +NAN }T

TESTING F*

T{ +0 +0 F* -> +0 }T
T{ +0 -0 F* -> -0 }T
T{ -0 +0 F* -> -0 }T
T{ -0 -0 F* -> +0 }T

T{ +0  2E F* -> +0 }T
T{ -0  2E F* -> -0 }T
T{ +0 -2E F* -> -0 }T
T{ -0 -2E F* -> +0 }T
T{  2E +0 F* -> +0 }T
T{  2E -0 F* -> -0 }T
T{ -2E +0 F* -> -0 }T
T{ -2E -0 F* -> +0 }T

T{ +NAN  2E  F* -> +NAN }T
T{ -NAN  2E  F* -> -NAN }T
T{  3E  +NAN F* -> +NAN }T
T{  3E  -NAN F* -> -NAN }T

T{ +NAN +NAN F*      -> +NAN }T
T{ -NAN +NAN F* FABS -> +NAN }T
T{ +NAN -NAN F* FABS -> +NAN }T
T{ -NAN -NAN F*      -> -NAN }T

T{  2E  +INF F* -> +INF }T
T{ +INF  7E  F* -> +INF }T
T{  2E  -INF F* -> -INF }T
T{ -INF  7E  F* -> -INF }T

T{ +NAN +INF F* -> +NAN }T
T{ +INF +NAN F* -> +NAN }T
T{ +NAN -INF F* -> +NAN }T
T{ -INF +NAN F* -> +NAN }T
T{ -NAN +INF F* -> -NAN }T
T{ +INF -NAN F* -> -NAN }T
T{ -NAN -INF F* -> -NAN }T
T{ -INF -NAN F* -> -NAN }T

T{ +INF +INF F* -> +INF }T
T{ +INF -INF F* -> -INF }T
T{ -INF +INF F* -> -INF }T

TESTING F/

T{ +0 +0 F/ FABS -> +NAN }T
T{ +0 -0 F/ FABS -> +NAN }T
T{ -0 +0 F/ FABS -> +NAN }T
T{ -0 -0 F/ FABS -> +NAN }T

T{ +0  2E F/ -> +0 }T
T{ -0  2E F/ -> -0 }T
T{ +0 -2E F/ -> -0 }T
T{ -0 -2E F/ -> +0 }T
T{  2E +0 F/ -> +INF }T
T{  2E -0 F/ -> -INF }T
T{ -2E +0 F/ -> -INF }T
T{ -2E -0 F/ -> +INF }T

T{ +NAN  2E  F/ -> +NAN }T
T{ -NAN  2E  F/ -> -NAN }T
T{  3E  +NAN F/ -> +NAN }T
T{  3E  -NAN F/ -> -NAN }T

T{ +NAN +NAN F/      -> +NAN }T
T{ -NAN +NAN F/ FABS -> +NAN }T
T{ +NAN -NAN F/ FABS -> +NAN }T
T{ -NAN -NAN F/      -> -NAN }T

T{  2E  +INF F/ -> +0 }T
T{ +INF  7E  F/ -> +INF }T
T{  2E  -INF F/ -> -0 }T
T{ -INF  7E  F/ -> -INF }T

T{ +NAN +INF F/ -> +NAN }T
T{ +INF +NAN F/ -> +NAN }T
T{ +NAN -INF F/ -> +NAN }T
T{ -INF +NAN F/ -> +NAN }T
T{ -NAN +INF F/ -> -NAN }T
T{ +INF -NAN F/ -> -NAN }T
T{ -NAN -INF F/ -> -NAN }T
T{ -INF -NAN F/ -> -NAN }T

T{ +INF +INF F/ FABS -> +NAN }T
T{ +INF -INF F/ FABS -> +NAN }T
T{ -INF +INF F/ FABS -> +NAN }T

TESTING FSQRT

T{ +0   FSQRT -> +0 }T
T{ -0   FSQRT -> -0 }T
T{ +INF FSQRT -> +INF }T
T{ -INF FSQRT -> -1E FSQRT }T
T{ +NAN FSQRT -> +NAN }T
T{ -NAN FSQRT -> -NAN }T
VALID-FNAN?-DEFINED [IF]
T{ -1E  FSQRT FNAN? -> TRUE }T
[ELSE]
VERBOSE @ [IF] .( NOT TESTING -1E FSQRT) CR [THEN]
[THEN]

?.ERRORS ?.CR

CR
CR .( END OF IEEE-ARITH-TEST.FS) CR
