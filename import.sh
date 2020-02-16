#!/bin/bash

DELIMITER=:

while IFS=$'\n' read -r line; do
    s=$line$DELIMITER
    array=();
    while [[ $s ]]; do
        array+=( "${s%%"$DELIMITER"*}" );
        s=${s#*"$DELIMITER"};
    done;

    # Variablize it so we know what we're dealing with
    ACCOUNT=${array[0]}
    ISSUER=${array[1]}
    SECRET=${array[2]}
    TOUCH_TRUE=${array[3]}
    OPTIONS=${array[4]}

    # if the account name and the secret are not set,
    # silently skip
    if [[ ! -z $ACCOUNT ]] && [[ ! -z $SECRET ]]; then
        echo $ACCOUNT
        echo $ISSUER
        echo $SECRET
        echo $TOUCH_TRUE
        echo $OPTIONS
    fi
done < ./$1



