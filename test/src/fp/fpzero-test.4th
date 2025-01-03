\ FPZERO-TEST.4TH
\
\ CHECK WHETHER OR NOT BASIC OPERATIONS WITH FLOATING POINT SIGNED ZERO IN A
\ FORTH SYSTEM ARE COMPATIBLE WITH IEEE 754 ARITHMETIC
\
\ KRISHNA MYNENI
\
\ REVISIONS:
\   2009-05-05  KM; CREATED
\
\ NOTES:
\
\ 1. BASED ON THE C PROGRAM ZEROSDQ.C, FROM
\
\    HTTP://WWW.MATH.UTAH.EDU/~BEEBE/SOFTWARE/IEEE/#TESTING-IS-NECESSARY
\
\ 2. THIS FORTH PROGRAM MAKES NO ASSUMPTIONS ABOUT THE INTERNAL REPRESENTATION
\    OF FLOATING POINT NUMBERS, UNLIKE THE ORIGINAL C PROGRAM, WHICH ASSUMES AN
\    IEEE FORMAT.
\ 
\ 3. SEVERAL ADDITIONAL TESTS ARE INCLUDED IN THE FORTH VERSION.

\ S" ANS-WORDS" INCLUDED
\ S" TTESTER"   INCLUDED

CR .( RUNNING FPZERO-TEST.4TH)
CR .( -----------------------) CR

TRUE VERBOSE !
DECIMAL

VARIABLE #ERRORS    0 #ERRORS !

: NONAME  ( C-ADDR U -- | KEEP A CUMULATIVE ERROR COUNT )
  1 #ERRORS +! ERROR1 ;  ' NONAME ERROR-XT !

-0E 0E 0E F~ [IF]
   
   CR CR .( ** SYSTEM DOES NOT SUPPORT FLOATING POINT SIGNED ZERO. **)
   CR    .( ** THEREFORE THESE TESTS HAVE BEEN SKIPPED **) CR
[ELSE]

VERBOSE @ [IF]
  CR CR .( SYSTEM SUPPORTS FP SIGNED ZERO. )
[THEN]

SET-EXACT

T{  0E  FNEGATE       ->  -0E     }T
T{ -0E  FABS          ->   0E     }T
T{  0E  F0=           ->   TRUE   }T
T{ -0E  F0=           ->   TRUE   }T
T{ -0E  0E F<         ->   FALSE  }T
T{  0E -0E F<         ->   FALSE  }T
T{ -0E  0E F>         ->   FALSE  }T
T{  0E -0E F>         ->   FALSE  }T
T{  0E  0E F-         ->   0E     }T
T{  0E FNEGATE 0E F-  ->  -0E     }T
T{  0E  1E F*         ->   0E     }T
T{  0E -1E F*         ->  -0E     }T

VERBOSE @ [IF]
CR .( #ERRORS: ) #ERRORS @ . CR
[THEN]

CR .( END OF FPZERO-TEST.4TH) CR
[THEN]

