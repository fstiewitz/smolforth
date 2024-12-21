#!/bin/bash

for f in $*
do
    echo -DSF_HAS_$(echo $f | tr '[[:lower:]]' '[[:upper:]]')=1
done
