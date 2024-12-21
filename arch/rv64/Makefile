ARCH=rv64
MEXT=imadc
EMU=qemu-riscv64 -L /opt/riscv/sysroot
ifeq ($(origin CC),default)
	CC=riscv64-unknown-linux-gnu-gcc
endif

include ../riscv/Makefile
