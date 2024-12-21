ARCH=rv32
MEXT=imadc
EMU=qemu-riscv32 -L /opt/riscv/sysroot
ifeq ($(origin CC),default)
	CC=riscv32-unknown-linux-gnu-gcc
endif

include ../riscv/Makefile
