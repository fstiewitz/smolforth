#!/bin/bash

function obj () {
    sed 's/\.c$/.o/'
}

ls *.c 2>/dev/null | obj
ls gen/*.c 2>/dev/null | obj
ls core/*.c 2>/dev/null | obj

for f in $*
do
    ls ../$f/*.c 2>/dev/null | obj
    ls ../../$f/*.c 2>/dev/null | obj
done
