\ FROM A.K. COMP.LANG.FORTH 2/4/2012
\ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\ BELOW IS SOME PRETTY OLD STUFF FOR TESTING SUM FP WORDS. DON'T KNOW IF IT
\ IS "COMPLIANT" OR CONSISTENT OR STRICTLY MATHEMATICALLY CORRECT. BUT PERHAPS
\ SOMEBODY MIGHT BE WILLING TO BRUSH IT UP.

0 [IF]
CHANGES MADE BY GERRY JACKSON
   1. VARIOUS AS MARKED FOR GFORTH
   2. TESTS WITH FLOATS FALIGNED ETC REMOVED AS SIZE OF A FLOAT IS
      IMPLEMENTATION DEFINED, THEREFORE ORIGINAL TESTS NOT PORTABLE
   3. THE FS. FE. AND F. TESTS HAVE BEEN KEPT ALTHOUGH DIFFERENT SYSTEMS
      HAVE A DIFFERENT INTERPRETATION OF 'SIGNIFICANT DIGITS' IN SET-PRECISION
[THEN]

\ THIS PROGRAM TESTS SOME OF THE FLOATING-POINT WORDS OF A MINFORTH SYSTEM

\ REQUIRE TTESTER.FS

CR .( RUNNING AK-FP-TEST.FTH)
CR .( ----------------------) CR  CR

TESTING --- MINFORTH FLOATING-POINT WORDS ---

\ : EMPTY-FPSTACK     \ ( F: ... -- ) EMPTY FLOATING-POINT STACK
\  BEGIN FDEPTH WHILE FDROP REPEAT ;

\ WARNING OFF
\ : }T FDEPTH 0<> ABORT" FP-STACK IS NOT EMPTY" }T ;
\ WARNING ON

\ EMPTY-FPSTACK
DECIMAL

\ ------------------------------------------------------------------------
TESTING BASIC FUNCTIONS

T{ -> }T        \ START    WITH CLEAN SLATE

T{ 0. D>F FDEPTH F>D -> 1 0. }T \ TEST THE WORDS USED IN EMPTY-FPSTACK
T{ 0. D>F FDROP FDEPTH -> 0 }T
T{ 0. D>F 0. D>F FDROP FDEPTH F>D -> 1 0. }T

T{ 0. D>F F>D -> 0. }T
T{ 1. D>F F>D -> 1. }T
T{ -1. D>F F>D -> -1. }T

\ IEEE754 MAX VALUE (52 BIT MANTISSA)
T{ HEX FFFFFFFFFFFFF. DECIMAL D>F F>D -> HEX FFFFFFFFFFFFF. DECIMAL }T

\ ------------------------------------------------------------------------
TESTING STACK OPERATIONS

T{ 1. D>F 2. D>F FSWAP F>D F>D -> 1. 2. }T
T{ 1. 2. 3. D>F D>F D>F FROT F>D F>D F>D -> 3. 1. 2. }T
T{ -7. D>F FDUP F>D F>D -> -7. -7. }T
T{ -4. D>F -2. D>F FOVER F>D F>D F>D -> -4. -2. -4. }T

\ ------------------------------------------------------------------------
TESTING BASIC ARITHMETICS

T{ 1. D>F FDUP F+ F>D -> 2. }T
T{ -2. D>F -3. D>F F+ F>D -> -5. }T

T{ 1. D>F FDUP F- F>D -> 0. }T
T{ -2. D>F -3. D>F F- F>D -> 1. }T

T{ 0. D>F FNEGATE F>D -> 0. }T
T{ 7. D>F FNEGATE F>D -> -7. }T
T{ -3. D>F FNEGATE F>D -> 3. }T

T{ 2. D>F FDUP F* F>D -> 4. }T
T{ -3. D>F FDUP F* F>D -> 9. }T
T{ -2. D>F 3. D>F F* F>D -> -6. }T
T{ 5. D>F -2. D>F F* F>D -> -10. }T
T{ 0. D>F -1. D>F F* F>D -> 0. }T
T{ 3. D>F 0. D>F F* F>D -> 0. }T

T{ 10. D>F 5. D>F F/ F>D -> 2. }T
T{ -33. D>F 11. D>F F/ F>D -> -3. }T
T{ 33. D>F -3. D>F F/ F>D -> -11. }T
T{ -14. D>F -7. D>F F/ F>D -> 2. }T
T{ 0. D>F 2. D>F F/ F>D -> 0. }T

\ ------------------------------------------------------------------------
TESTING COMPARISONS

T{ 1. D>F F0< -> FALSE }T
T{ 0. D>F F0< -> FALSE }T
T{ -1. D>F F0< -> TRUE }T

T{ 0. D>F F0= -> TRUE }T
T{ 1. D>F F0= -> FALSE }T
T{ -2. D>F F0= -> FALSE }T

T{ 1. D>F 2. D>F F< -> TRUE }T
T{ 2. D>F 0. D>F F< -> FALSE }T
T{ 0. D>F -2. D>F F< -> FALSE }T
T{ -3. D>F -2. D>F F< -> TRUE }T

T{ 1. D>F FABS F>D -> 1. }T
T{ -2. D>F FABS F>D -> 2. }T

T{ -2. D>F 1. D>F FMAX F>D -> 1. }T
T{ -1. D>F -2. D>F FMAX F>D -> -1. }T
T{ -1. D>F 0. D>F FMAX F>D -> 0. }T
T{ 0. D>F -1. D>F FMAX F>D -> 0. }T
T{ 1. D>F 2. D>F FMIN F>D -> 1. }T
T{ -3. D>F -4. D>F FMIN F>D -> -4. }T
T{ 1. D>F 0. D>F FMIN F>D -> 0. }T
T{ 0. D>F -2. D>F FMIN F>D -> -2. }T

T{ 10. D>F 11. D>F 1. D>F F~ -> FALSE }T
T{ -10. D>F -11. D>F 2. D>F F~ -> TRUE }T
T{ 1. D>F 2. D>F 1. D>F F~ -> FALSE }T

T{ 0. D>F FDUP FDUP F~ -> TRUE }T
T{ 1. D>F FDUP 0. D>F F~ -> TRUE }T
T{ -2. D>F FDUP 0. D>F F~ -> TRUE }T
T{ 3. D>F 4. D>F 0. D>F F~ -> FALSE }T

T{ 2. D>F 3. D>F -1. D>F 5. D>F F/ F~ -> FALSE }T
T{ 2. D>F 3. D>F -2. D>F 5. D>F F/ F~ -> TRUE }T
T{ -2. D>F -3. D>F -1. D>F 5. D>F F/ F~ -> FALSE }T
T{ -2. D>F -3. D>F -2. D>F 5. D>F F/ F~ -> TRUE }T

\ ------------------------------------------------------------------------
TESTING MEMORY ACCESS, FLITERAL, FCONSTANT, FVARIABLE

VARIABLE FMEM 2 CELLS ALLOT

T{ 1. D>F FMEM F! -> }T
T{ FMEM F@ F>D -> 1. }T

FMEM 2 CELLS ERASE
T{ -2. D>F FMEM SF! -> }T
T{ FMEM SF@ F>D -> -2. }T
T{ FMEM CELL+ @ -> 0 }T

T{ 3. D>F FMEM DF! -> }T
T{ FMEM DF@ F>D -> 3. }T

: FT1 [ -2. D>F ] FLITERAL ;
T{ FT1 F>D -> -2. }T

-3. D>F FCONSTANT FT2
T{ FT2 F>D -> -3. }T

FVARIABLE FT4
T{ -4. D>F FT4 F! -> }T
T{ FT4 F@ F>D -> -4. }T

0 [IF]  TESTS REMOVED AS SIZE OF A FLOAT IS IMPLEMENTATION DEPENDENT
T{ 0 FLOATS -> 0 }T
T{ 1 FLOATS -> 8 }T
T{ -1 FLOATS -> -8 }T
T{ 0 SFLOATS -> 0 }T
T{ 1 SFLOATS -> 4 }T
T{ -1 SFLOATS -> -4 }T
T{ 0 DFLOATS -> 0 }T
T{ 1 DFLOATS -> 8 }T
T{ -1 DFLOATS -> -8 }T
T{ 0 FLOAT+ -> 8 }T
T{ 0 SFLOAT+ -> 4 }T
T{ 0 DFLOAT+ -> 8 }T

T{ 8 FALIGNED -> 8 }T
T{ 9 FALIGNED -> 16 }T
T{ 10 FALIGNED -> 16 }T
T{ 11 FALIGNED -> 16 }T
T{ 12 FALIGNED -> 16 }T
T{ 13 FALIGNED -> 16 }T
T{ 14 FALIGNED -> 16 }T
T{ 15 FALIGNED -> 16 }T
T{ 16 FALIGNED -> 16 }T
T{ 17 FALIGNED -> 24 }T

T{ 4 SFALIGNED -> 4 }T
T{ 5 SFALIGNED -> 8 }T
T{ 6 SFALIGNED -> 8 }T
T{ 7 SFALIGNED -> 8 }T
T{ 8 SFALIGNED -> 8 }T
T{ 9 SFALIGNED -> 12 }T

T{ 8 DFALIGNED -> 8 }T
T{ 9 DFALIGNED -> 16 }T
T{ 10 DFALIGNED -> 16 }T
T{ 11 DFALIGNED -> 16 }T
T{ 12 DFALIGNED -> 16 }T
T{ 13 DFALIGNED -> 16 }T
T{ 14 DFALIGNED -> 16 }T
T{ 15 DFALIGNED -> 16 }T
T{ 16 DFALIGNED -> 16 }T
T{ 17 DFALIGNED -> 24 }T

T{ 0 C, FALIGN HERE 7 AND -> 0 }T
T{ 0 C, DFALIGN HERE 7 AND -> 0 }T
T{ 0 C, SFALIGN HERE 3 AND -> 0 }T
T{ FALIGN HERE FALIGN HERE = -> TRUE }T
T{ DFALIGN HERE DFALIGN HERE = -> TRUE }T
T{ SFALIGN HERE SFALIGN HERE = -> TRUE }T
[THEN]
T{ 0  FLOATS -> 0 }T
T{ 0 SFLOATS -> 0 }T
T{ 0 DFLOATS -> 0 }T

\ ------------------------------------------------------------------------
TESTING NUMBER INPUT
\ LEADING AND TRAILING SPACES REMOVED FROM STRINGS BECAUSE ANS FORTH
\ DOES NOT SPECIFY THEY SHOULD BE IGNORED

T{ S" ." >FLOAT -> FALSE }T
T{ S" .E" >FLOAT -> FALSE }T
T{ S" +.E+0" >FLOAT -> FALSE }T
T{ S" E" >FLOAT -> FALSE }T
T{ S" 0E" >FLOAT F>D -> TRUE 0. }T
T{ S" 1E" >FLOAT F>D -> TRUE 1. }T
T{ S" 1.E" >FLOAT F>D -> TRUE 1. }T
T{ S" 1.E0" >FLOAT F>D -> TRUE 1. }T
T{ S" 1.2E+1" >FLOAT F>D -> TRUE 12. }T
T{ S" +1.2E1" >FLOAT F>D -> TRUE 12. }T
T{ S" 120E-1" >FLOAT F>D -> TRUE 12. }T
T{ S" -120E-1" >FLOAT F>D -> TRUE -12. }T

T{ S" 1F" >FLOAT -> FALSE }T  \ CHECK AGAINST C FLOATS
T{ S" 1D" >FLOAT F>D -> TRUE 1. }T
T{ S" -1D" >FLOAT F>D -> TRUE -1. }T

T{ S" 1EE" >FLOAT -> FALSE }T
T{ S" 1DD" >FLOAT -> FALSE }T
T{ S" 1E1E" >FLOAT -> FALSE }T
T{ S" 1E 1E" >FLOAT -> FALSE }T
T{ S" 1E  1E" >FLOAT -> FALSE }T

T{ PAD 0 >FLOAT F>D -> TRUE 0. }T
T{ S"   " >FLOAT F>D -> TRUE 0. }T  \ SPECIAL CASE

T{ S" 2.0D0" >FLOAT F>D -> TRUE 2. }T     \ MODIFIED TO MAKE IT COMPLIANT
T{ S" 2.0D+0" >FLOAT F>D -> TRUE 2. }T    \ MODIFIED TO MAKE IT COMPLIANT
T{ S" -2.0E-0" >FLOAT F>D -> TRUE -2. }T  \ MODIFIED TO MAKE IT COMPLIANT

T{ 1.0E0 F>D -> 1. }T
T{ -2.0E1 F>D -> -20. }T
T{ 200.0E-1 F>D -> 20. }T                 \ MODIFIED TO MAKE IT COMPLIANT
T{ +300.0E+02 F>D -> 30000. }T            \ MODIFIED TO MAKE IT COMPLIANT
T{ 10E F>D -> 10. }T
T{ -10E-1 F>D -> -1. }T

\ ------------------------------------------------------------------------
TESTING FRACTIONAL ARITHMETICS
DECIMAL

: F=    ( R1 R2 -- FLAG, TRUE IF EXACT IDENTITIY )
  0E F~ ;

: TF=   ( R1 R2 -- FLAG, TRUE IF ABS. ERROR < 0.00005 )
  0.00005E F~ ;

T{ 1.E 1.00005E TF= -> FALSE }T
T{ 1.E 1.00004E TF= -> TRUE }T

T{ 3.33333E 6.66666E F+ 10E TF= -> TRUE }T
T{ 10E 6.66666E F- 3.33333E TF= -> TRUE }T
T{ 2E 0.02E F* 0.04E TF= -> TRUE }T
T{ 10E 3E F/ 3.3333E TF= -> TRUE }T
T{ -3E-3 FNEGATE +3E-3 F= -> TRUE }T

T{ 2E FLOOR 2E F= -> TRUE }T
T{ 1.5E FLOOR 1E F= -> TRUE }T
T{ -0.5E FLOOR -1E F= -> TRUE }T
T{ 0E FLOOR 0E F= -> TRUE }T
T{ -0E FLOOR -0E F= -> TRUE }T            \ MODIFIED TO AGREE WITH GFORTH

T{ 2E FROUND 2E F= -> TRUE }T
T{ 1.5E FROUND 2E F= -> TRUE }T
T{ 1.4999E FROUND 1E F= -> TRUE }T
T{ -0.4999E FROUND -0E F= -> TRUE }T      \ MODIFIED TO AGREE WITH GFORTH
T{ -0.5001E FROUND -1E F= -> TRUE }T
\ T{ 2.5E FROUND 2E F= -> TRUE }T

T{ 4E FSQRT 2E TF= -> TRUE }T
T{ 2E FSQRT 1.4142E TF= -> TRUE }T
T{ 0E FSQRT 0E F= -> TRUE }T
T{ 1E FSQRT 1E F= -> TRUE }T

\ ------------------------------------------------------------------------
TESTING TRIGONOMETRIC FUNCTIONS

[UNDEFINED] PI [IF]
   3.1415926535897932384626433832795E FCONSTANT PI
[THEN]
PI   0.5E F* FCONSTANT PI2/
PI2/ 0.5E F* FCONSTANT PI4/

T{ 0E FSIN 0E F= -> TRUE }T
T{ PI FSIN 0E TF= -> TRUE }T
T{ PI2/ FSIN 1E TF= -> TRUE }T
T{ PI4/ FSIN 0.7071E TF= -> TRUE }T
T{ PI FNEGATE FSIN 0E TF= -> TRUE }T
T{ PI2/ FNEGATE FSIN 1E FNEGATE TF= -> TRUE }T
T{ PI4/ FNEGATE FSIN -0.7071E TF= -> TRUE }T
T{ 10E FSIN -0.5440E TF= -> TRUE }T

T{ 0E FCOS 1E F= -> TRUE }T
T{ PI FCOS 1E FNEGATE TF= -> TRUE }T
T{ PI2/ FCOS 0E TF= -> TRUE }T
T{ PI4/ FCOS 0.7071E TF= -> TRUE }T
T{ PI FNEGATE FCOS 1E FNEGATE TF= -> TRUE }T
T{ PI2/ FNEGATE FCOS 0E TF= -> TRUE }T
T{ PI4/ FNEGATE FCOS 0.7071E TF= -> TRUE }T
T{ 10E FCOS -0.8391E TF= -> TRUE }T

T{ 0E FSINCOS 1E F= 0E F= -> TRUE TRUE }T
T{ PI4/ FSINCOS F- 0E TF= -> TRUE }T
T{ 2.3562E FSINCOS F+ 0E TF= -> TRUE }T

T{ 0E FTAN 0E F= -> TRUE }T
T{ PI FTAN 0E TF= -> TRUE }T
T{ PI4/ FTAN 1E TF= -> TRUE }T
T{ PI 6E F/ FTAN 0.57735E TF= -> TRUE }T
T{ PI FNEGATE FTAN 0E TF= -> TRUE }T
T{ PI 6E F/ FNEGATE FTAN -0.57735E TF= -> TRUE }T
T{ PI4/ FNEGATE FTAN 1E FNEGATE TF= -> TRUE }T
T{ 10E FTAN 0.6484E TF= -> TRUE }T

T{ 0E FASIN 0E F= -> TRUE }T
T{ 0.5E FASIN PI F/ 0.1667E TF= -> TRUE }T
T{ 1E FASIN PI F/ 0.5E TF= -> TRUE }T
T{ -1E FASIN PI F/ -0.5E TF= -> TRUE }T

T{ 1E FACOS 0E TF= -> TRUE }T
T{ 0.5E FACOS PI F/ 0.3333E TF= -> TRUE }T
T{ 0E FACOS PI F/ 0.5E TF= -> TRUE }T
T{ -1E FACOS PI TF= -> TRUE }T

T{ 0E FATAN 0E F= -> TRUE }T
T{ 1E FATAN 0.7854E TF= -> TRUE }T
T{ 0.5E FATAN 0.4636E TF= -> TRUE }T
T{ -1E FATAN -0.7854E TF= -> TRUE }T

T{ 0E 1E FATAN2 0E F= -> TRUE }T
T{ 1E 1E FATAN2 0.7854E TF= -> TRUE }T
T{ -1E 1E FATAN2 -0.7854E TF= -> TRUE }T
T{ -1E -1E FATAN2 -2.3562E TF= -> TRUE }T
T{ 1E -1E FATAN2 2.3562E TF= -> TRUE }T

\ ------------------------------------------------------------------------
TESTING EXPONENTIAL AND LOGARITHMIC FUNCTIONS

T{ 0E FEXP 1E F= -> TRUE }T
T{ 1E FEXP 2.7183E TF= -> TRUE }T
T{ -1E FEXP 0.3679E TF= -> TRUE }T

T{ 0E FEXPM1 0E F= -> TRUE }T
T{ 1E FEXPM1 1.7183E TF= -> TRUE }T
T{ -1E FEXPM1 -0.6321E TF= -> TRUE }T

T{ 1E FLN 0E F= -> TRUE }T
T{ 2.7183E FLN 1E TF= -> TRUE }T
T{ 0.36788E FLN -1E TF= -> TRUE }T

T{ 1E FLOG 0E F= -> TRUE }T
T{ 0.1E FLOG -1E TF= -> TRUE }T
T{ 10E FLOG 1E TF= -> TRUE }T

T{ 0E FLNP1 0E F= -> TRUE }T
T{ 1E FLNP1 0.6931E TF= -> TRUE }T
T{ -0.63212E FLNP1 -1E TF= -> TRUE }T

T{ 1E 0E F** 1E F= -> TRUE }T
T{ 2E 2E F** 4E TF= -> TRUE }T
T{ 2E 0.5E F** 1.4142E TF= -> TRUE }T

T{ 0E FALOG 1E F= -> TRUE }T
T{ 1E FALOG 10E TF= -> TRUE }T
T{ -1E FALOG 0.1E TF= -> TRUE }T

\ ------------------------------------------------------------------------
TESTING HYPERBOLIC FUNCTIONS

T{ 0E FSINH 0E F= -> TRUE }T
T{ -1E FSINH -1.1752E TF= -> TRUE }T
T{ 1E FSINH 1.1752E TF= -> TRUE }T

T{ 0E FCOSH 1E F= -> TRUE }T
T{ 1E FCOSH 1.5431E TF= -> TRUE }T
T{ -1E FCOSH 1.5431E TF= -> TRUE }T

T{ 0E FTANH 0E F= -> TRUE }T
T{ 1E FTANH 0.7616E TF= -> TRUE }T
T{ -1E FTANH -0.7616E TF= -> TRUE }T

T{ 0E FASINH 0E F= -> TRUE }T
T{ -1E FASINH -0.8814E TF= -> TRUE }T
T{ 1E FASINH 0.8814E TF= -> TRUE }T

T{ 1E FACOSH 0E F= -> TRUE }T
T{ 2E FACOSH 1.317E TF= -> TRUE }T

\ ------------------------------------------------------------------------
TESTING NUMBER OUTPUT

CREATE FBUF 20 ALLOT
FBUF 20 ERASE

T{ 1E FBUF 5 REPRESENT -> 1 0 TRUE }T           \ MODIFIED TO AGREE WITH GFORTH
T{ S" 10000" FBUF 5 COMPARE -> 0 }T
\ T{ FBUF 5 + C@ -> 0 }T                        \ NOT REQUIRED

T{ -1E FBUF 5 REPRESENT -> 1 -1 TRUE }T
T{ S" 10000" FBUF 5 COMPARE -> 0 }T

T{ 100E 3E F/ FBUF 5 REPRESENT -> 2 0 TRUE }T   \ MODIFIED TO AGREE WITH GFORTH
T{ S" 33333" FBUF 5 COMPARE -> 0 }T
T{ 0.02E 3E F/ FBUF 5 REPRESENT -> -2 0 TRUE }T \ MODIFIED TO AGREE WITH GFORTH
T{ S" 66667" FBUF 5 COMPARE -> 0 }T

CR .( CHECKING FS. )

: YSS  \ ( A U -- ) TYPE A NEW OUTPUT CHECK LINE
CR ." YOU MIGHT SEE " TYPE ."  : " ;

5 SET-PRECISION

1E S" 1.0000E0 " YSS FS.         \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
20E S" 2.0000E1 " YSS FS.        \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
0.02E S" 2.0000E-2" YSS FS.      \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
-333.E2 S" -3.3300E4" YSS FS.    \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
10E 3E F/ S" 3.3333E0 " YSS FS.
0.2E 3E F/ S" 6.6667E-2" YSS FS.

CR .( CHECKING FE. )

1E S" 1.0000E0 " YSS FE.         \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
20E S" 20.000E0 " YSS FE.        \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
300E S" 300.00E0 " YSS FE.       \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
4000E S" 4.0000E3 " YSS FE.      \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
1E 3E F/ S" 333.33E-3" YSS FE.
2E4 3E F/ S" 6.6667E3 " YSS FE.

CR .( CHECKING F. )

1E3 S" 1000.  " YSS F.
1.1E3 S" 1100.  " YSS F.
1E 3E F/ S" 0.33333" YSS F.
200E 3E F/ S" 66.667 " YSS F.
0.000234E S" 0.00023" YSS F.     \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
0.000236E S" 0.00024" YSS F.     \ MODIFIED TO AGREE WITH GFORTH & WIN32 FORTH
\ -------------------------------------------------------------------------------------

CR
CR .( END OF AK-FP-TEST.FTH) CR
