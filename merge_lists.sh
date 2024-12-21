#!/bin/bash

OBJ=$1
READELF=${2%-*}-readelf

shift
shift

cat $* > gen/core.coll.txt
$READELF --wide -s "$OBJ" |
    awk '{print $7, $5, $8}' |
    grep -v '^UND' |
    awk '{print $2, $3}' |
    grep '^GLOBAL' |
    awk '{print "({" $2 "},"}' |
    sed -e 's/^({FORTH\$/({/' > gen/out.sym.txt
fgrep -v -f gen/out.sym.txt gen/core.coll.txt > gen/core.txt.tmp
mv gen/core.txt.tmp gen/core.txt
