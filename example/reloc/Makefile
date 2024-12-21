# TUT The rule fmain.o showcases a typical object file compilation.
# TUT Because this project does not link back to a full smolforth,
# TUT we also include the following files from the sources:
# TUT  - stack.c defines C functions for manipulating the stacks.
# TUT  - boot.S defines wrappers for switching calling conventions.
# TUT
# TUT You can now read `example/reloc/fmain.fth`

.PHONY: clean

example.out: fmain.o main.o stack.o boot.o core.o
	$(CC) -g -o $@ $^

fmain.o: fmain.fth
	../../arch/x86_64/smolforth ../../reloc-setup.fth ../../quit.fth ../../detached.fth ../../reloc-run.fth -- -c fmain.fth > out.txt
	../../reloc/obj-x86_64
	mv out.o fmain.o

%.o: %.c
	$(CC) -g -I ../.. -I ../../arch/x86_64 -o $@ -c $^

%.o: %.S
	$(CC) -g -I../../core -I ../.. -I ../../arch/x86_64 -o $@ -c $^

%.o: ../../arch/x86_64/%.c
	$(CC) -g -I ../.. -I ../../arch/x86_64 -o $@ -c $^

%.o: ../../arch/x86_64/%.S
	$(CC) -g -I ../.. -I ../../arch/x86_64 -o $@ -c $^

%.o: ../../core/%.c
	$(CC) -g -I ../.. -I ../../arch/x86_64 -o $@ -c $^

clean:
	rm -f *.o
	rm -f example
	rm -f out.*
