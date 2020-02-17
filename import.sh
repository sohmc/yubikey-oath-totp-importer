#!/bin/bash

DELIMITER=:
YKMAN_BIN=/usr/bin/ykman

YKMAN=`${YKMAN_BIN} -v`

if [[ $? != 0 ]]; then
    echo "ykman command not found.  Please install it before using"
    echo "this script.  Instructions can be found here:"
    echo "    https://developers.yubico.com/yubikey-manager/"
    exit 1
fi

echo "You are about to install OATH tokens onto the yubikey."
echo "Doing so will ERASE ALL CURRENT tokens and REPLACE them."
echo "THIS CANNOT BE UNDONE!"
read -p "Are you sure you want to continue? " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Erasing your current OATH tokens..."
    ${YKMAN_BIN} oath reset --force

    while IFS=$'\n' read -r line; do
        if [[ ${line:0:1} != "#" ]]; then
            s=$line$DELIMITER
            array=();
            while [[ $s ]]; do
                array+=( "${s%%"$DELIMITER"*}" );
                s=${s#*"$DELIMITER"};
            done;

            # Variablize it so we know what each column is.
            ACCOUNT=${array[0]}
            ISSUER=${array[1]}
            SECRET=${array[2]}
            TOUCH_TRUE=${array[3]}
            OPTIONS=${array[4]}

            # if the account name and the secret are not set,
            # silently skip
            if [[ ! -z $ACCOUNT ]] && [[ ! -z $SECRET ]]; then
                # Always force otherwise user-interaction is required
                FLAGS="--force"

                # If there are options set, then append them here
                if [[ ! -z $OPTIONS ]]; then
                    FLAGS+=" ${OPTIONS}"
                fi

                # If $ISSUER is set, then add it
                if [[ ! -z $ISSUER ]]; then
                    ISSUER="--issuer ${ISSUER}"
                fi

                # If $TOUCH_TRUE is set OR if FORCE_TOUCH is set,
                # then enable touch.
                if [[ $TOUCH_TRUE == "t" ]] || [[ $FORCE_TOUCH == "t" ]]; then
                    TOUCH="--touch"
                else
                    TOUCH=""
                fi

                ${YKMAN_BIN} oath add \
                    --force \
                    ${OPTIONS} \
                    ${ISSUER} \
                    ${TOUCH} \
                    "${ACCOUNT}" \
                    "${SECRET}"
            fi
        fi
    done < ./$1
fi
