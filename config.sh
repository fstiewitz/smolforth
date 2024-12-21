#!/bin/bash

tf=$1

shift

for f in $*
do
    if [[ -e ../../$f/$tf ]]
    then
        cat ../../$f/$tf
    fi
done
