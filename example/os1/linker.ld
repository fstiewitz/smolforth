ENTRY(start);
 
. = 0x80000000;

MEMORY {
	ram (wx) : ORIGIN = 0x80000000, LENGTH = 0x8000000
}

PHDRS {
	text PT_LOAD;
	rodata PT_LOAD;
	data PT_LOAD;
	fs PT_LOAD;
}
 
SECTIONS {
	/* Include entry point at start of binary */
	.text : ALIGN(4K) {
		*(.text.INIT);
		*(.text.*);
		*(.text);
	} :text
	.bss : ALIGN(4K) {
		PROVIDE(BSS_START = .);
		*(.bss);
		. += 4096;
		PROVIDE(STACK_TOP = .);
		. += 4096;
		PROVIDE(TRAP_STACK_TOP = .);
		PROVIDE(DATA_STACK_BOTTOM = .);
		. += 4096;
		PROVIDE(RETURN_STACK_BOTTOM = .);
		. += 4096;
		PROVIDE(TRAP_DATA_STACK_BOTTOM = .);
		. += 4096;
		PROVIDE(TRAP_RETURN_STACK_BOTTOM = .);
		. += 4096;
		. += 4096;
		PROVIDE(TRAP_STACK_TOP = .);
		. += 4096;
		PROVIDE(GLOBAL_POINTER = .);
		PROVIDE(BSS_END = .);
	}
	.rodata : ALIGN(4K) {
		*(.rodata);
	}
	.data : ALIGN(4K) {
		*(.data);
	} :data
}
