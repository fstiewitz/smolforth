# TUT This example prints Hello, World in a RISC-V kernel. Most of the code will be related to OS-dev
# TUT and won't be explained here.
# TUT
# TUT There is one thing of note: `libsmolforth-EmbFrsCrSt.a` is a core archive generated during the building of smolforth.
# TUT  - It is (Emb)edded, meaning it does not contain compilation words or "extra" words that have dependencies (like FM/MOD, SM/REM, UM/MOD).
# TUT  - It is (Fr)ee(s)tanding, meaning it does not contain words that have platform dependencies (like anything I/O).
# TUT  - It includes (C)o(r)e words.
# TUT  - It includes (St)ring words.
# TUT
# TUT `cores.txt` is a line-separated list of core archives that will be generated during build_all.sh
# TUT
# TUT The last lesson is in `example/os1/fmain.fth`.
# TUT
# TUT `example/os2` is a full smolforth running as a RISC-V OS-Kernel.
# TUT If you  execute `build_all.sh rv64`, the test suite will also be executed on it.

.PHONY: clean

PREFIX=riscv64-unknown-elf
CC=$(PREFIX)-gcc
LD=$(PREFIX)-ld
CFLAGS=-mcmodel=medany -I../.. -I../../arch/riscv -I../../arch/rv64

kernel.elf: kernel.a linker.ld ../../arch/rv64/libsmolforth-EmbFrsCrSt.a
	$(LD) -T linker.ld -nostdlib --start-group kernel.a ../../arch/rv64/libsmolforth-EmbFrsCrSt.a --end-group -o kernel.elf

kernel.a: fmain.o stack.o boot.o to_body.o core.o math.o
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
	rm -f *.a
	rm -f *.o
	rm -f *.elf
	rm -f example.*
	rm -f out.*
