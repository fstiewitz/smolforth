#!/bin/bash

exec < ../../cores.txt

while read args
do
    ../../build_embedded.sh ${args}
    ../../build_freestanding.sh ${args}
done
