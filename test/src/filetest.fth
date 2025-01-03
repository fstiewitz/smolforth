\ To test the ANS File Access word set and extension words

\ This program was written by Gerry Jackson in 2006, with contributions from
\ others where indicated, and is in the public domain - it can be distributed
\ and/or modified in any way but please retain this notice.

\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

\ The tests are not claimed to be comprehensive or correct 

\ ------------------------------------------------------------------------------
\ The tests are based on John Hayes test program for the core word set
\ and requires those files to have been loaded

\ Words tested in this file are:
\     ( BIN CLOSE-FILE CREATE-FILE DELETE-FILE FILE-POSITION FILE-SIZE
\     OPEN-FILE R/O R/W READ-FILE READ-LINE REPOSITION-FILE RESIZE-FILE 
\     S" S\" SOURCE-ID W/O WRITE-FILE WRITE-LINE 
\     FILE-STATUS FLUSH-FILE RENAME-FILE SAVE-INPUT RESTORE-INPUT
\     REFILL

\ Words not tested:
\     INCLUDED INCLUDE-FILE (as these will likely have been
\     tested in the execution of the test files)
\ ------------------------------------------------------------------------------
\ Assumptions, dependencies and notes:
\     - tester.fr (or ttester.fs), errorreport.fth and utilities.fth have been
\       included prior to this file
\     - the Core word set is available and tested
\     - These tests create files in the current directory, if all goes
\       well these will be deleted. If something fails they may not be
\       deleted. If this is a problem ensure you set a suitable 
\       directory before running this test. There is no ANS standard
\       way of doing this. Also be aware of the file names used below
\       which are:  fatest1.txt, fatest2.txt and fatest3.txt
\ ------------------------------------------------------------------------------

TESTING File Access word set

DECIMAL

\ ------------------------------------------------------------------------------
TESTING CREATE-FILE CLOSE-FILE

: FN1 S" fatest1.txt" ;
VARIABLE FID1

T{ FN1 R/W CREATE-FILE SWAP FID1 ! -> 0 }T
T{ FID1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------
TESTING OPEN-FILE W/O WRITE-LINE

: LINE1 S" Line 1" ;

T{ FN1 W/O OPEN-FILE SWAP FID1 ! -> 0 }T
T{ LINE1 FID1 @ WRITE-LINE -> 0 }T
T{ FID1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------
TESTING R/O FILE-POSITION (simple)  READ-LINE 

200 CONSTANT BSIZE
CREATE BUF BSIZE ALLOT
VARIABLE #CHARS

T{ FN1 R/O OPEN-FILE SWAP FID1 ! -> 0 }T
T{ FID1 @ FILE-POSITION -> 0 0 0 }T
T{ BUF 100 FID1 @ READ-LINE ROT DUP #CHARS ! -> TRUE 0 LINE1 SWAP DROP }T
T{ BUF #CHARS @ LINE1 S= -> TRUE }T
T{ FID1 @ CLOSE-FILE -> 0 }T

\ Additional test contributed by Helmut Eller
\ Test with buffer shorter than the line including zero length buffer.
T{ FN1 R/O OPEN-FILE SWAP FID1 ! -> 0 }T
T{ FID1 @ FILE-POSITION -> 0 0 0 }T
T{ BUF 0 FID1 @ READ-LINE ROT DUP #CHARS ! -> TRUE 0 0 }T
T{ BUF 3 FID1 @ READ-LINE ROT DUP #CHARS ! -> TRUE 0 3 }T
T{ BUF #CHARS @ LINE1 DROP 3 S= -> TRUE }T
T{ BUF 100 FID1 @ READ-LINE ROT DUP #CHARS ! -> TRUE 0 LINE1 NIP 3 - }T
T{ BUF #CHARS @ LINE1 3 /STRING S= -> TRUE }T
T{ FID1 @ CLOSE-FILE -> 0 }T

\ Additional test contributed by Helmut Eller
\ Test with buffer exactly as long as the line.
T{ FN1 R/O OPEN-FILE SWAP FID1 ! -> 0 }T
T{ FID1 @ FILE-POSITION -> 0 0 0 }T
T{ BUF LINE1 NIP FID1 @ READ-LINE ROT DUP #CHARS ! -> TRUE 0 LINE1 NIP }T
T{ BUF #CHARS @ LINE1 S= -> TRUE }T
T{ FID1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------
TESTING S" in interpretation mode (compile mode tested in Core tests)

T{ S" abcdef" $" abcdef" S= -> TRUE }T
T{ S" " $" " S= -> TRUE }T
T{ S" ghi"$" ghi" S= -> TRUE }T

\ ------------------------------------------------------------------------------
TESTING R/W WRITE-FILE REPOSITION-FILE READ-FILE FILE-POSITION S"

: LINE2 S" Line 2 blah blah blah" ;
: RL1  BUF 100 FID1 @ READ-LINE  ;
CREATE FP 0 , 0 ,    \ Don't use 2VARIABLE
: DEQ  ( d -- f )  ROT = >R = R> AND  ;  \ Same as D= in Double Number word set

T{ FN1 R/W OPEN-FILE SWAP FID1 ! -> 0 }T
T{ FID1 @ FILE-SIZE DROP FID1 @ REPOSITION-FILE -> 0 }T
T{ FID1 @ FILE-SIZE -> FID1 @ FILE-POSITION }T
T{ LINE2 FID1 @ WRITE-FILE -> 0 }T
T{ 10 0 FID1 @ REPOSITION-FILE -> 0 }T
T{ FID1 @ FILE-POSITION -> 10 0 0 }T
T{ 0 0 FID1 @ REPOSITION-FILE -> 0 }T
T{ RL1 -> LINE1 SWAP DROP TRUE 0 }T
T{ RL1 ROT DUP #CHARS ! -> TRUE 0 LINE2 SWAP DROP }T
T{ BUF #CHARS @ LINE2 S= -> TRUE }T
T{ RL1 -> 0 FALSE 0 }T
T{ FID1 @ FILE-POSITION ROT ROT FP 2! -> 0 }T
T{ FP 2@ FID1 @ FILE-SIZE DROP DEQ -> TRUE }T
T{ S" " FID1 @ WRITE-LINE -> 0 }T
T{ S" " FID1 @ WRITE-LINE -> 0 }T
T{ FP 2@ FID1 @ REPOSITION-FILE -> 0 }T
T{ RL1 -> 0 TRUE 0 }T
T{ RL1 -> 0 TRUE 0 }T
T{ RL1 -> 0 FALSE 0 }T
T{ FID1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------
TESTING BIN READ-FILE FILE-SIZE

: CBUF BUF BSIZE 0 FILL ;
: FN2 S" FATEST2.TXT" ;
VARIABLE FID2
: SETPAD PAD 50 0 DO I OVER C! CHAR+ LOOP DROP ;

SETPAD   \ If anything else is defined setpad must be called again
         \ as pad may move

T{ FN2 R/W BIN CREATE-FILE SWAP FID2 ! -> 0 }T
T{ PAD 50 FID2 @ WRITE-FILE FID2 @ FLUSH-FILE -> 0 0 }T
T{ FID2 @ FILE-SIZE -> 50 0 0 }T
T{ 0 0 FID2 @ REPOSITION-FILE -> 0 }T
T{ CBUF BUF 29 FID2 @ READ-FILE -> 29 0 }T
T{ PAD 29 BUF 29 S= -> TRUE }T
T{ PAD 30 BUF 30 S= -> FALSE }T
T{ CBUF BUF 29 FID2 @ READ-FILE -> 21 0 }T
T{ PAD 29 + 21 BUF 21 S= -> TRUE }T
T{ FID2 @ FILE-SIZE DROP FID2 @ FILE-POSITION DROP DEQ -> TRUE }T
T{ BUF 10 FID2 @ READ-FILE -> 0 0 }T
T{ FID2 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------
TESTING RESIZE-FILE

T{ FN2 R/W BIN OPEN-FILE SWAP FID2 ! -> 0 }T
T{ 37 0 FID2 @ RESIZE-FILE -> 0 }T
T{ FID2 @ FILE-SIZE -> 37 0 0 }T
T{ 0 0 FID2 @ REPOSITION-FILE -> 0 }T
T{ CBUF BUF 100 FID2 @ READ-FILE -> 37 0 }T
T{ PAD 37 BUF 37 S= -> TRUE }T
T{ PAD 38 BUF 38 S= -> FALSE }T
T{ 500 0 FID2 @ RESIZE-FILE -> 0 }T
T{ FID2 @ FILE-SIZE -> 500 0 0 }T
T{ 0 0 FID2 @ REPOSITION-FILE -> 0 }T
T{ CBUF BUF 100 FID2 @ READ-FILE -> 100 0 }T
T{ PAD 37 BUF 37 S= -> TRUE }T
T{ FID2 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------
TESTING DELETE-FILE

T{ FN2 DELETE-FILE -> 0 }T
T{ FN2 R/W BIN OPEN-FILE SWAP DROP 0= -> FALSE }T
T{ FN2 DELETE-FILE 0= -> FALSE }T

\ ------------------------------------------------------------------------------
TESTING multi-line ( comments

T{ ( 1 2 3
4 5 6
7 8 9 ) 11 22 33 -> 11 22 33 }T

\ ------------------------------------------------------------------------------
TESTING SOURCE-ID (can only test it does not return 0 or -1)

T{ SOURCE-ID DUP -1 = SWAP 0= OR -> FALSE }T

\ ------------------------------------------------------------------------------
TESTING RENAME-FILE FILE-STATUS FLUSH-FILE

: FN3 S" fatest3.txt" ;
: >END FID1 @ FILE-SIZE DROP FID1 @ REPOSITION-FILE ;


T{ FN3 DELETE-FILE DROP -> }T
T{ FN1 FN3 RENAME-FILE 0= -> TRUE }T
T{ FN1 FILE-STATUS SWAP DROP 0= -> FALSE }T
T{ FN3 FILE-STATUS SWAP DROP 0= -> TRUE }T  \ Return value is undefined
T{ FN3 R/W OPEN-FILE SWAP FID1 ! -> 0 }T
T{ >END -> 0 }T
T{ S" Final line" FID1 @ WRITE-LINE -> 0 }T
T{ FID1 @ FLUSH-FILE -> 0 }T      \ Can only test FLUSH-FILE doesn't fail
T{ FID1 @ CLOSE-FILE -> 0 }T

\ Tidy the test folder
T{ FN3 DELETE-FILE DROP -> }T

\ ------------------------------------------------------------------------------
TESTING REQUIRED REQUIRE INCLUDED
\ Tests taken from Forth 2012 RfD

T{ 0
  S" required-helper1.fth" REQUIRED
  REQUIRE required-helper1.fth
  INCLUDE required-helper1.fth
  -> 2 }T
T{ 0
  INCLUDE required-helper2.fth
  S" required-helper2.fth" REQUIRED
  REQUIRE required-helper2.fth
  S" required-helper2.fth" INCLUDED
  -> 2 }T
  
\ ------------------------------------------------------------------------------
TESTING S\" (Forth 2012 interpretation mode)

\ S\" in compilation mode already tested in Core Extension tests
T{ : SSQ11 S\" \a\b\e\f\l\m\q\r\t\v\x0F0\x1Fa\xaBx\z\"\\" ; -> }T
T{ S\" \a\b\e\f\l\m\q\r\t\v\x0F0\x1Fa\xaBx\z\"\\" SSQ11  S= -> TRUE }T

\ ------------------------------------------------------------------------------
TESTING two buffers available for S" and/or S\" (Forth 2012)

: SSQ12 S" abcd" ;   : SSQ13 S" 1234" ;
T{ S" abcd"  S" 1234" SSQ13  S= ROT ROT SSQ12 S= -> TRUE TRUE }T
T{ S\" abcd" S\" 1234" SSQ13 S= ROT ROT SSQ12 S= -> TRUE TRUE }T
T{ S" abcd"  S\" 1234" SSQ13 S= ROT ROT SSQ12 S= -> TRUE TRUE }T
T{ S\" abcd" S" 1234" SSQ13  S= ROT ROT SSQ12 S= -> TRUE TRUE }T


\ ------------------------------------------------------------------------------
TESTING SAVE-INPUT and RESTORE-INPUT with a file source

VARIABLE SIV -1 SIV !

: NEVEREXECUTED
   CR ." This should never be executed" CR
;

T{ 11111 SAVE-INPUT

SIV @

[?IF]
\?   0 SIV !
\?   RESTORE-INPUT
\?   NEVEREXECUTED
\?   33333
[?ELSE]

\? TESTING the -[ELSE]- part is executed
\? 22222

[?THEN]

   -> 11111 0 22222 }T   \ 0 comes from RESTORE-INPUT

TESTING nested SAVE-INPUT, RESTORE-INPUT and REFILL from a file

: READ_A_LINE
   REFILL 0=
   ABORT" REFILL FAILED"
;

0 SI_INC !

CREATE 2RES -1 , -1 ,   \ Don't use 2VARIABLE from Double number word set 

: SI2
   READ_A_LINE
   READ_A_LINE
   SAVE-INPUT
   READ_A_LINE
   READ_A_LINE
   S$ EVALUATE 2RES 2!
   RESTORE-INPUT
;

\ WARNING: do not delete or insert lines of text after si2 is called
\ otherwise the next test will fail

T{ SI2
33333               \ This line should be ignored
2RES 2@ 44444      \ RESTORE-INPUT should return to this line

55555
TESTING the nested results
 -> 0 0 2345 44444 55555 }T

\ End of warning

\ ------------------------------------------------------------------------------

FILE-ERRORS SET-ERROR-COUNT

CR .( End of File-Access word set tests) CR
