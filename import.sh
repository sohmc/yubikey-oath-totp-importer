#!/bin/bash

# read file
if [[ -f $1 ]]; then
    CONFIG_FILE=$1
fi

delimiter=:

while IFS=$'\n' read -r line; do
    s=$line$delimiter
    array=();
    while [[ $s ]]; do
        array+=( "${s%%"$delimiter"*}" );
        s=${s#*"$delimiter"};
    done;

    echo ${array[0]}
done < ./$1



