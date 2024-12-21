0 STATE SYS:WDATA !
.( \ Setting up a dedicated 1MB CDATA .init section ) CR
CSPACE
.( \ Allocating space ) CR
CREATE INIT-SPACE 1024 1024 * ALLOT
.( \ Creating section ) CR
INIT-SPACE DUP 1024 1024 * + 1 SECTION INIT
' INIT >BODY ADD-SECTION
.( \ Enabling section ) CR
INIT

CSPACE

INCLUDE ramdisk.fth

VOCABULARY HOST

' FORTH >BODY @ ' HOST >BODY !
