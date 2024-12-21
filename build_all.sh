#!/bin/bash

set -e

export PATH="/opt/riscv/bin:$PATH"

TESTFILES="runtests.fth"
FPTESTFILES="runfptests.fth"

P="$PWD"

function rv64() {
    INC='core search facility file double string memory block tools float O2'
    make -C arch/rv64 clean INC="$INC"
    make -C arch/rv64 -j12 INC="$INC"
    cd test/src
    qemu-riscv64 -L /opt/riscv/sysroot ../../arch/rv64/smolforth ../../quit.fth $TESTFILES <<< "hello" | tee ../../rv64.txt
    cd fp
    qemu-riscv64 -L /opt/riscv/sysroot ../../../arch/rv64/smolforth ../../../quit.fth $FPTESTFILES | tee -a ../../../rv64.txt
    cd ../../../example/os0
    make clean && make && ./run.sh -serial stdio | tee -a ../../rv64.txt
    cd ../os1
    make clean && make && ./run.sh -serial stdio | tee -a ../../rv64.txt
    cd ../os2
    make clean && make && (sleep 3; echo 'INCLUDE runtests.fth'; echo hello) | ./run.sh -serial stdio | tee -a ../../rv64.txt
}

function rv32() {
    INC='core search facility file double string memory block tools float O2'
    make -C arch/rv32 clean INC="$INC"
    make -C arch/rv32 -j12 INC="$INC"
    cd test/src
    qemu-riscv32 -L /opt/riscv/sysroot ../../arch/rv32/smolforth ../../quit.fth $TESTFILES <<< "hello" | tee ../../rv32.txt
    cd fp
    qemu-riscv32 -L /opt/riscv/sysroot ../../../arch/rv32/smolforth ../../../quit.fth $FPTESTFILES | tee -a ../../../rv32.txt
}


function x86_64() {
    INC='core search facility file double string memory block tools float'
    make -C arch/x86_64 clean INC="$INC"
    make -C arch/x86_64 -j12 INC="$INC"
    cd test/src
    ../../arch/x86_64/smolforth ../../quit.fth $TESTFILES <<< "hello" | tee ../../x86_64.txt
    cd fp
    ../../../arch/x86_64/smolforth ../../../quit.fth $FPTESTFILES | tee -a ../../../x86_64.txt
    cd ../../../example/reloc
    make clean && make && ./example.out | tee -a ../../x86_64.txt
}

if [[ $1 ]]
then
    $1
    cd "$P"
    if diff -u $1.txt test.expected.$1.txt
    then
        rm -f $1.txt
    else
        echo "$1 bad"
    fi
else

rv64
cd "$P"
rv32
cd "$P"
x86_64
cd "$P"

if diff -u rv64.txt test.expected.rv64.txt
then
    rm -f rv64.txt
else
    echo "RV64 bad"
fi

if diff -u rv32.txt test.expected.rv32.txt
then
    rm -f rv32.txt
else
    echo "RV32 bad"
fi

if diff -u x86_64.txt test.expected.x86_64.txt
then
    rm -f x86_64.txt
else
    echo "X86_64 bad"
fi

fi
