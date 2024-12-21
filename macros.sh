#!/bin/bash

ls *.m4 2>/dev/null
ls core/*.m4 2>/dev/null

for f in $*
do
    ls ../$f/*.m4 2>/dev/null
    ls ../../$f/*.m4 2>/dev/null
    ls $f/*.m4 2>/dev/null
done
