CFLAGS+=-mcmodel=medany -march=${ARCH}${MEXT} -g -I. -I../.. -I../riscv
LIBS=$(shell ../../config.sh libs riscv ${INC})

OBJECTS=$(shell ../../objects.sh riscv ${INC})

COREM4=$(shell ../../macros.sh riscv ${INC})

LISTS=$(shell ../../lists.sh riscv ${INC})

M4DEF=$(shell ../../m4def.sh riscv ${INC}) -DIEEE754_2008=1
M4DEFB=$(shell ../../m4defb.sh riscv ${INC})

M4SRC=config.m4 ../../gen/core.S.m4 $(COREM4) aux_words.txt $(LISTS) ../../gen/core_end.S.m4

.PHONY: clean

cores: smolforth
	CC=$(CC) CFLAGS="$(CFLAGS)" ARCH=riscv SUBARCH=$(ARCH) EMU="$(EMU)" ORIG_OBJECTS="$(OBJECTS)" ORIG_LIBS="$(LIBS)" ../../build_cores.sh

smolforth: $(OBJECTS) gen/core_out.o ../riscv/boot.o out.o
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
	../../make-elf-writable $@ .text

smolforth-boot: $(OBJECTS) gen/core.o ../riscv/boot.o
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
	../../make-elf-writable $@ .text

reloc:
	$(MAKE) -C ../../reloc ${ARCH}

out.o: smolforth-boot reloc ../../extensions.fth
	${EMU} ./smolforth-boot ../../reloc-setup.fth ../../facility-code.fth ../../facility0.fth ../../file.fth ../../extensions-boot.fth ../../reloc-run.fth > out.txt
	../../reloc/obj-${ARCH}
	cp out.o bootstrapped.o
	$(CC) $(M4DEF) $(CFLAGS) -o ../riscv/main.o -c ../riscv/main.c
	$(CC) $(M4DEF) $(CFLAGS) -o ../riscv/plt.o -c ../riscv/plt.c

gen/core.o: gen/core.S
	$(CC) $(CFLAGS) -o $@ -c $^

gen/core.S: $(M4SRC)
	m4 $(M4DEF) $^ > gen/core.S

gen/core_out.o: gen/core_out.S
	$(CC) $(CFLAGS) -o $@ -c $^

gen/core_out.S: out.o $(M4SRC)
	../../merge_lists.sh out.o $(CC) $(LISTS)
	m4 $(M4DEF) $(M4DEFB) config.m4 ../../gen/core.S.m4 $(COREM4) aux_words.txt gen/core.txt ../../gen/core_end.S.m4 > gen/core_out.S


%.o: %.S
	$(CC) $(M4DEF) $(CFLAGS) -o $@ -c $^

core/ENVIRONMENT_question.o: core/ENVIRONMENT_question.c
	../../environ.sh ${ARCH} ${INC}
	$(CC) $(M4DEF) $(CFLAGS) -o $@ -c $^

%.o: %.c
	$(CC) $(M4DEF) $(CFLAGS) -o $@ -c $^

clean:
	rm -f out.*
	touch out.h
	rm -f ../riscv/out.*
	touch ../riscv/out.h
	rm -f smolforth
	rm -f smolforth-boot
	rm -f *.o
	rm -f *.a
	rm -f gen/*
	rm -f core/*.o
	../../clean.sh riscv ${INC}
