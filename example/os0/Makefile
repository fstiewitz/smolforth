.PHONY: clean

PREFIX=riscv64-unknown-elf
CC=$(PREFIX)-gcc
LD=$(PREFIX)-ld
CFLAGS=-I../.. -I../../arch/riscv -I../../arch/rv64

kernel.elf: kernel.a linker.ld
	$(LD) -T linker.ld -nostdlib kernel.a -o kernel.elf

kernel.a: fmain.o stack.o boot.o to_body.o core.o
	ar rcs $@ $^

fmain.o: fmain.fth
	qemu-riscv64 -L /opt/riscv/sysroot ../../arch/rv64/smolforth ../../reloc-setup.fth ../../quit.fth ../../detached.fth setup.fth ../../reloc-run.fth -- -c fmain.fth > out.txt
	../../reloc/obj-rv64
	mv out.o fmain.o

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $^

%.o: %.S
	$(CC) -I../../core $(CFLAGS) -o $@ -c $^

%.o: ../../arch/riscv/%.c
	$(CC) $(CFLAGS) -o $@ -c $^

%.o: ../../arch/riscv/%.S
	$(CC) $(CFLAGS) -o $@ -c $^

%.o: ../../core/%.c
	$(CC) $(CFLAGS) -o $@ -c $^

clean:
	rm -f *.o
	rm -f *.elf
	rm -f example.*
	rm -f out.*
