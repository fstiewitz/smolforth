\ TUT In the example below, you can see messages printed out at compile-time.
\ TUT These are actually relocation and symbol statements. reloc-run.fth prints
\ TUT these whenever you compile a call to something, but we write some of them
\ TUT manually here, because their addresses are not known at compile-time.
\ TUT You probably won't need to use this, but in a special case like this:
\ TUT
\ TUT The syntax of these statements is probably subject to change,
\ TUT require knowledge of ELF and depend on what's going on in `reloc/obj.cpp`,
\ TUT but to annotate just one:
\ TUT
\ TUT  `HERE . .( 0 0 QUOTE DATA_STACK_BOTTOM 0 RELOC-ADDR ) CR`
\ TUT  - The first value is the address of the relocation.
\ TUT  - Next is the addend (0).
\ TUT  - The word address (0 because its not a Forth word).
\ TUT  - `QUOTE` to quote the next item.
\ TUT  - The name of the symbol.
\ TUT  - The relocation subtype (in reloc/obj.cpp:684, type 0 refers to a 32-bit PC-relative address).
\ TUT  - The relocation type.
\ TUT The actual symbol is defined in the linker script linker.ld, by the way.
\ TUT
\ TUT You can see the syntax is suitable to be parsed by another Forth application.
\ TUT But it's not. It's written in C++.
\ TUT
\ TUT Aaaand that's it.

INIT
HEX

HERE . .( 0 QUOTE start SYMBOL ) CR
ALSO ASSEMBLER
    HERE . .( 0 0 QUOTE GLOBAL_POINTER 0 RELOC-ADDR ) CR
    GP 0 *AUIPC
    GP GP 0 *ADDI

    HERE . .( 0 0 QUOTE STACK_TOP 0 RELOC-ADDR ) CR
    SP 0 *AUIPC
    SP SP 0 *ADDI

    HERE . .( 0 0 QUOTE DATA_STACK_BOTTOM 0 RELOC-ADDR ) CR
    S0 0 *AUIPC
    S0 S0 0 *ADDI

    HERE . .( 0 0 QUOTE RETURN_STACK_BOTTOM 0 RELOC-ADDR ) CR
    S1 0 *AUIPC
    S1 S1 0 *ADDI

    X0 X0 SATP *CSRRW

    HERE . .( 0 0 QUOTE TRAP_STACK_TOP 0 RELOC-ADDR ) CR
    T0 0 *AUIPC
    T0 T0 0 *ADDI
    X0 T0 MSCRATCH *CSRRW

    T0 X0 MSTATUS *CSRRS
    T0 *PUSH
    ] FFFFFFF7 AND [
    T0 *POP
    X0 T0 MSTATUS *CSRRW

    HERE . .( 0 0 QUOTE FORTH$body$TRAP_ENTRY 0 RELOC-ADDR ) CR
    T0 0 *AUIPC
    T0 T0 0 *ADDI
    X0 T0 MTVEC *CSRRW

    ] B00 [
    T0 *POP
    X0 T0 MIE *CSRRW

    T0 X0 MSTATUS *CSRRS
    T0 *PUSH
    ] BB OR [
    T0 *POP
    X0 T0 MSTATUS *CSRRW

    HERE . .( 0 0 QUOTE FORTH$body$KMAIN 0 RELOC-ADDR ) CR
    T0 0 *AUIPC
    T0 T0 0 *ADDI
    X0 T0 MEPC *CSRRW

    HERE . .( 0 0 QUOTE BSS_START 0 RELOC-ADDR ) CR
    T0 0 *AUIPC
    T0 T0 0 *ADDI
    T0 *PUSH
    HERE . .( 0 0 QUOTE BSS_END 0 RELOC-ADDR ) CR
    T0 0 *AUIPC
    T0 T0 0 *ADDI
    T0 *PUSH
    ] OVER - 0 FILL [

    HERE . .( 0 0 QUOTE FORTH$body$KMAIN 0 RELOC-EXECUTE ) CR
    RA 0 *AUIPC
    RA RA 0 *JALR

    ] 5555 100000 [
    A1 1 *FETCH
    A0 2 *FETCH
    A0 A1 0 *SW
    ] BEGIN [ *WFI ] AGAIN [

PREVIOUS

DECIMAL
CODE TRAP_ENTRY
    SP SP MSCRATCH *CSRRW
    SP SP -32 CELLS *ADDI
    X1 SP 1 CELLS *SD
    X2 SP 2 CELLS *SD
    X3 SP 3 CELLS *SD
    X4 SP 4 CELLS *SD
    X5 SP 5 CELLS *SD
    X6 SP 6 CELLS *SD
    X7 SP 7 CELLS *SD
    X8 SP 8 CELLS *SD
    X9 SP 9 CELLS *SD
    X10 SP 10 CELLS *SD
    X11 SP 11 CELLS *SD
    X12 SP 12 CELLS *SD
    X13 SP 13 CELLS *SD
    X14 SP 14 CELLS *SD
    X15 SP 15 CELLS *SD
    X16 SP 16 CELLS *SD
    X17 SP 17 CELLS *SD
    X18 SP 18 CELLS *SD
    X19 SP 19 CELLS *SD
    X20 SP 20 CELLS *SD
    X21 SP 21 CELLS *SD
    X22 SP 22 CELLS *SD
    X23 SP 23 CELLS *SD
    X24 SP 24 CELLS *SD
    X25 SP 25 CELLS *SD
    X26 SP 26 CELLS *SD
    X27 SP 27 CELLS *SD
    X28 SP 28 CELLS *SD
    X29 SP 29 CELLS *SD
    X30 SP 30 CELLS *SD
    X31 SP 31 CELLS *SD
HEX

    HERE . .( 0 0 QUOTE TRAP_DATA_STACK_BOTTOM 0 RELOC-ADDR ) CR
    S0 0 *AUIPC
    S0 S0 0 *ADDI

    HERE . .( 0 0 QUOTE TRAP_RETURN_STACK_BOTTOM 0 RELOC-ADDR ) CR
    S1 0 *AUIPC
    S1 S1 0 *ADDI

    A0 X0 MCAUSE *CSRRS
    A0 *PUSH

    HERE . .( 0 0 QUOTE FORTH$body$IRQ_ENTRY 0 RELOC-EXECUTE ) CR
    RA 0 *AUIPC
    RA RA 0 *JALR

DECIMAL
    X1 SP 1 CELLS *LD
    X2 SP 2 CELLS *LD
    X3 SP 3 CELLS *LD
    X4 SP 4 CELLS *LD
    X5 SP 5 CELLS *LD
    X6 SP 6 CELLS *LD
    X7 SP 7 CELLS *LD
    X8 SP 8 CELLS *LD
    X9 SP 9 CELLS *LD
    X10 SP 10 CELLS *LD
    X11 SP 11 CELLS *LD
    X12 SP 12 CELLS *LD
    X13 SP 13 CELLS *LD
    X14 SP 14 CELLS *LD
    X15 SP 15 CELLS *LD
    X16 SP 16 CELLS *LD
    X17 SP 17 CELLS *LD
    X18 SP 18 CELLS *LD
    X19 SP 19 CELLS *LD
    X20 SP 20 CELLS *LD
    X21 SP 21 CELLS *LD
    X22 SP 22 CELLS *LD
    X23 SP 23 CELLS *LD
    X24 SP 24 CELLS *LD
    X25 SP 25 CELLS *LD
    X26 SP 26 CELLS *LD
    X27 SP 27 CELLS *LD
    X28 SP 28 CELLS *LD
    X29 SP 29 CELLS *LD
    X30 SP 30 CELLS *LD
    X31 SP 31 CELLS *LD

    SP SP 32 CELLS *ADDI
    SP SP MSCRATCH *CSRRW
    *MRET
END-CODE

CSPACE

: IRQ_ENTRY ( mcause -- )
    DROP
;

VOCABULARY IO:UART
ALSO IO:UART DEFINITIONS

BEGIN-STRUCTURE UART:CTL
    0 +FIELD UART:CTL:RBR
    0 +FIELD UART:CTL:THR
    1 +FIELD UART:CTL:DLL
    0 +FIELD UART:CTL:IER
    1 +FIELD UART:CTL:DLM
    0 +FIELD UART:CTL:IIR
    1 +FIELD UART:CTL:FCR
    CFIELD: UART:CTL:LCR
    CFIELD: UART:CTL:MCR
    CFIELD: UART:CTL:LSR
    CFIELD: UART:CTL:MSR
END-STRUCTURE

HEX
10000000 CONSTANT IO:UART:BASEPTR

ALSO FORTH DEFINITIONS

: IO:UART:INIT
    3 IO:UART:BASEPTR UART:CTL:LCR C!
    1 IO:UART:BASEPTR UART:CTL:FCR C!
    IO:UART:BASEPTR UART:CTL:LCR DUP C@ 80 OR SWAP C!
    0C DUP
    FF AND IO:UART:BASEPTR UART:CTL:DLL C!
    8 RSHIFT IO:UART:BASEPTR UART:CTL:DLM C!
    3 IO:UART:BASEPTR UART:CTL:LCR C!
    1 IO:UART:BASEPTR UART:CTL:IER C!
;

: EMIT
    IO:UART:BASEPTR UART:CTL:THR C!
    BEGIN
        IO:UART:BASEPTR UART:CTL:LSR C@ 60 AND 60 =
    UNTIL
;

: CR 0D EMIT 0A EMIT ;

: TYPE
    BEGIN
        DUP 0<>
    WHILE
        OVER C@ EMIT
        1 /STRING
    REPEAT
    2DROP
;

ONLY FORTH DEFINITIONS

: KMAIN ( -- )
    IO:UART:INIT
    ." Hello, World" CR
    ."  -- from example/os1" CR
;
