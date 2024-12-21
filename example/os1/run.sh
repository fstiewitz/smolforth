#!/bin/bash
QEMU=qemu-system-riscv64
MACH=virt
RUN="$QEMU -machine $MACH"
RUN="$RUN -bios kernel.elf"
#RUN="$RUN -device VGA"
#RUN="$RUN -chardev pty,id=ttypci -device pci-serial,chardev=ttypci"

exec ${RUN} "${@}"
