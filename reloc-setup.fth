\ TUT These comments serve as an introduction to object file compilation with
\ TUT smolforth. Object file compilation (called Relocation in smolforth because
\ TUT that's the challenging part) is the process of taking your compiled
\ TUT Forth code and putting it into an object file in such a way that you can
\ TUT include that object file in any project without needing to link back to smolforth.
\ TUT Relocation is not built into smolforth. Instead, relocation is provided
\ TUT by two forth scripts. The typical invocation of smolforth is as follows:
\ TUT
\ TUT     smolforth \
\ TUT         reloc-setup.fth \
\ TUT         [detached.fth] \
\ TUT         [your-setup.fth and other files] \
\ TUT         reloc-run.fth -- -c fmain.fth > out.txt
\ TUT
\ TUT - reloc-setup.fth (this file) sets up a few words that are needed to keep
\ TUT track of word lists and sections.
\ TUT - The optional detached.fth creates separate sections for initialized data,
\ TUT uninitialized data, code and word definitions.
\ TUT - Next you can include code that will not be placed in the object file,
\ TUT but you still need. For example, the OS-Kernels in `example/os*` need
\ TUT an additional `.init` section for the entry point.
\ TUT - reloc-run.fth finally finishes the relocation setup, parses the command-line
\ TUT arguments that follow, includes `fmain.fth` and generates raw binary dumps
\ TUT named `out*.bin`, a header for C in `out.h` and a textual description of all symbols and relocations in `out.txt`.
\ TUT
\ TUT Next, you call `reloc/obj-x86_64` to read `out.txt` and `out*.bin` and
\ TUT assemble an `out.o` object file.
\ TUT
\ TUT You can now continue reading at detached.fth

CONTEXT @ @ CONSTANT SAVE-CORE

VARIABLE SECTIONS
VARIABLE SECTION-COUNT
0 SECTION-COUNT !

: INC-SECTION ( -- addr )
    SECTION-COUNT @ 0= IF
        4 CELLS ALLOCATE THROW SECTIONS !
    ELSE
        SECTIONS @ SECTION-COUNT @ 1+ 4 CELLS * RESIZE THROW
        SECTIONS !
    THEN
    SECTIONS @ SECTION-COUNT @ 4 CELLS * +
;

: ADD-SECTION ( ptr -- )
    >R
    0
    BEGIN
        DUP SECTION-COUNT @ = INVERT
    WHILE
        DUP 4 * CELLS SECTIONS @ + @ R@ = IF
            R> DROP
            DROP
            EXIT
        THEN
        1+
    REPEAT
    DROP
    R>
    INC-SECTION \ ptr section-end
    2DUP ! CELL+
    2DUP SWAP 2 CELLS + @ SWAP ! CELL+
    2DUP SWAP 3 CELLS + @ SWAP ! CELL+
    SWAP 4 CELLS + @ SWAP !
    1 SECTION-COUNT +!
;

VARIABLE R:CONTEXT
VARIABLE R:COUNT
0 R:COUNT !

: INC-CONTEXT ( -- addr )
    R:COUNT @ 0= IF
        1 CELLS ALLOCATE THROW R:CONTEXT !
    ELSE
        R:CONTEXT @ R:COUNT @ 1+ CELLS RESIZE THROW
        R:CONTEXT !
    THEN
    R:CONTEXT @ R:COUNT @ CELLS +
;

: ADD-WORDLIST ( ptr -- )
    >R
    0
    BEGIN
        DUP R:COUNT @ = INVERT
    WHILE
        DUP CELLS R:CONTEXT @ + @ R@ = IF
            R> DROP
            DROP
            EXIT
        THEN
        1+
    REPEAT
    DROP
    R>
    INC-CONTEXT !
    1 R:COUNT +!
;
