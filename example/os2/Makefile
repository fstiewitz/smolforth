.PHONY: clean

PREFIX=riscv64-unknown-elf
CC=$(PREFIX)-gcc
LD=$(PREFIX)-ld
CFLAGS=-mcmodel=medany -I../.. -I../../arch/riscv -I../../arch/rv64

kernel.elf: kernel.a linker.ld ../../arch/rv64/libsmolforth-FrsCrDoMeStToWlO2.a
	$(LD) -T linker.ld -nostdlib --start-group kernel.a ../../arch/rv64/libsmolforth-FrsCrDoMeStToWlO2.a --end-group /opt/riscv/lib/gcc/riscv64-unknown-linux-gnu/13.2.0/libgcc.a -o kernel.elf

kernel.a: fmain.o stack.o boot.o to_body.o core.o math.o stl.o
	ar rcs $@ $^

fmain.o: fmain.fth uart.fth plic.fth memory.fth
	tar --xform s:^.*/:: -c -v -f test-cat.tar ../../test/src/*.fr ../../test/src/*.fth
	tar --delete -v -f test-cat.tar runtests.fth
	tar -u -v -f test-cat.tar runtests.fth
	qemu-riscv64 -L /opt/riscv/sysroot ../../arch/rv64/smolforth ../../reloc-setup.fth ../../quit.fth ../../detached.fth setup.fth ../../reloc-run.fth -- -c fmain.fth > out.txt
	../../reloc/obj-rv64
	riscv64-linux-gnu-objcopy --redefine-sym 'FORTH$$out__end=FORTH$$out__end__emb' out.o fmain.o

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
	rm -f *.a
	rm -f *.o
	rm -f *.elf
	rm -f example.*
	rm -f out.*
