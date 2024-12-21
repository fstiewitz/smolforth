CC=x86_64-linux-gnu-gcc

CFLAGS=-g -I. -I../.. -O0 -fno-fast-math
LIBS=$(shell ../../config.sh libs ${INC})

OBJECTS=$(shell ../../objects.sh ${INC})

COREM4=$(shell ../../macros.sh ${INC})

LISTS=$(shell ../../lists.sh ${INC})

M4DEF=$(shell ../../m4def.sh ${INC})
M4DEFB=$(shell ../../m4defb.sh ${INC})

M4SRC=config.m4 ../../gen/core.S.m4 $(COREM4) aux_words.txt $(LISTS) ../../gen/core_end.S.m4

.PHONY: clean

cores: smolforth
	CC=$(CC) CFLAGS="$(CFLAGS)" SUBARCH=x86_64 ARCH=x86_64 ORIG_OBJECTS="$(OBJECTS)" ORIG_LIBS="$(LIBS)" ../../build_cores.sh

smolforth: $(OBJECTS) gen/core_out.o boot.o out.o
	ar rcs $@.a $^
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
	../../make-elf-writable $@ .text

smolforth-boot: $(OBJECTS) gen/core.o boot.o
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
	../../make-elf-writable $@ .text

reloc:
	$(MAKE) -C ../../reloc x86_64

out.o: smolforth-boot reloc ../../extensions.fth
	./smolforth-boot ../../reloc-setup.fth ../../facility-code.fth ../../facility0.fth ../../file.fth ../../extensions-boot.fth ../../reloc-run.fth > out.txt
	../../reloc/obj-x86_64
	$(CC) $(M4DEF) $(CFLAGS) -o main.o -c main.c

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
	../../environ.sh x86_64 ${INC}
	$(CC) $(M4DEF) $(CFLAGS) -o $@ -c $^

%.o: %.c
	$(CC) $(M4DEF) $(CFLAGS) -o $@ -c $^

clean:
	rm -f out.*
	touch out.h
	rm -f smolforth
	rm -f smolforth-boot
	rm -f *.o
	rm -f gen/*
	rm -f core/*.o
	../../clean.sh ${INC}
