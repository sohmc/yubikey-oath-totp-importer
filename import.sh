#!/bin/bash

# read file
if [[ -f $1 ]]; then
    CONFIG_FILE=$1
fi

while IFS=$':' read -r line; do
    
done < ./$1
