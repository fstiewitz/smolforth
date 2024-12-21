#!/bin/bash

INC="freestanding embedded $*"

SUFFIX=$(../../libsuffix.pl ${INC})
PREFIX=${CC%-*}
LIBS=$(../../config.sh libs ${ARCH} ${INC})
OBJECTS=$(../../objects.sh ${ARCH} ${INC})
COREM4=$(../../macros.sh ${ARCH} ${INC})
LISTS=$(../../lists.sh ${ARCH} ${INC})
M4DEF=$(../../m4def.sh ${ARCH} ${INC})
M4DEFB=$(../../m4defb.sh ${ARCH} ${INC})
M4SRC="config.m4 ../../gen/core.S.m4 ${COREM4} aux_words.txt ${LISTS} ../../gen/core_end.S.m4"

# rebuild env
 ../../environ.sh ${SUBARCH} $*
 ${CC} $(../../m4def.sh ${ARCH} $*) -DSF_WANTS_EMBEDDED=1 ${CFLAGS} -o core/ENVIRONMENT_question.o -c core/ENVIRONMENT_question.c
# relink smolforth
${CC} ${CFLAGS} -o smolforth.emb ${ORIG_OBJECTS} gen/core_out.o ../${ARCH}/boot.o bootstrapped.o ${ORIG_LIBS}
../../make-elf-writable smolforth.emb .text
# compile
${EMU} ./smolforth.emb ../../reloc-setup.fth ../../quit.fth ../../reloc-run.fth -- -c boot-emb.fth > out.txt
../../reloc/obj-${SUBARCH}
${PREFIX}-objcopy --redefine-sym 'FORTH$out__end=CORE_last' out.o
# new core.S
m4 ${M4DEF} ${M4SRC} > gen/core-emb.S
${CC} ${CFLAGS} -o gen/core-emb.o -c gen/core-emb.S
 ${CC} ${M4DEF} ${CFLAGS} -o core/ENVIRONMENT_question.o -c core/ENVIRONMENT_question.c
# create archive
ar rcs libsmolforth-${SUFFIX}.a gen/core-emb.o out.o core/ENVIRONMENT_question.o
