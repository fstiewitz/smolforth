#!/bin/bash

INC="freestanding $*"

SUFFIX=$(../../libsuffix.pl ${INC})
PREFIX=${CC%-*}
LIBS=$(../../config.sh libs ${ARCH} ${INC})
OBJECTS=$(../../objects.sh ${ARCH} ${INC} | grep -v -F -f freestanding.ignore)
COREM4=$(../../macros.sh ${ARCH} ${INC})
LISTS=$(../../lists.sh ${ARCH} ${INC})
M4DEF=$(../../m4def.sh ${ARCH} ${INC})
M4DEFB=$(../../m4defb.sh ${ARCH} ${INC})
M4SRC="config.m4 ../../gen/core.S.m4 ${COREM4} aux_words.txt ${LISTS} ../../gen/core_end.S.m4"

# rebuild env
 ../../environ.sh ${SUBARCH} $*
 ${CC} $(../../m4def.sh ${ARCH} $*) -DSF_WANTS_FREESTANDING=1 ${CFLAGS} -o core/ENVIRONMENT_question.o -c core/ENVIRONMENT_question.c
# relink smolforth
${CC} ${CFLAGS} -o smolforth.emb ${ORIG_OBJECTS} gen/core_out.o ../${ARCH}/boot.o bootstrapped.o ${ORIG_LIBS}
../../make-elf-writable smolforth.emb .text
# compile
${EMU} ./smolforth.emb ../../reloc-setup.fth ../../quit.fth ../../reloc-run.fth -- -c boot-emb.fth > out.txt
../../reloc/obj-${SUBARCH}
${PREFIX}-objcopy --redefine-sym 'FORTH$out__end=CORE_last' out.o
# new core.S
../../merge_lists.sh out.o ${CC} ${LISTS}
m4 ${M4DEF} ${M4DEFB} config.m4 ../../gen/core.S.m4 ${COREM4} aux_words.txt gen/core.txt ../../gen/core_end.S.m4 > gen/core-emb.S
${CC} ${CFLAGS} -o gen/core-emb.o -c gen/core-emb.S
 ${CC} ${M4DEF} ${M4DEFB} ${CFLAGS} -o core/ENVIRONMENT_question.o -c core/ENVIRONMENT_question.c
# recompile objects
rm -f *.o.free.o
for f in ${OBJECTS}
do
    ${CC} ${M4DEF} ${M4DEFB} ${CFLAGS} -ffreestanding -o "$f.free.o" -c "${f%.*}.c"
done
# create archive
ar rcs libsmolforth-${SUFFIX}.a $(echo ${OBJECTS} | sed 's/\.o/.o.free.o/g') gen/core-emb.o out.o core/ENVIRONMENT_question.o

