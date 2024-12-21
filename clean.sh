#!/bin/bash

for f in $*
do
    echo "clean $f"
    rm -f ../$f/*.o
    rm -f ../../$f/*.o
done
