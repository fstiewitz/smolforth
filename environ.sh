#!/bin/bash

Q=../../arch/$1/environment_queries.h
F=../../arch/$1/environment_functions.h

rm -f $Q
rm -f $F

touch $Q
touch $F

shift

cat environment_queries.hh >> $Q
cat environment_functions.hh >> $F

for f in $*
do
    if [[ -f ../../$f/environment_queries.h ]]
    then
        cat ../../$f/environment_queries.h >> $Q
    fi
    if [[ -f ../../$f/environment_functions.h ]]
    then
        cat ../../$f/environment_functions.h >> $F
    fi
done
