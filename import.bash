#!/bin/bash

DELIMITER=:
YKMAN_BIN=/usr/bin/ykman

YKMAN=`"${YKMAN_BIN}" -v`

if [[ $? != 0 ]]; then
    echo "ykman command not found.  Please install it before using"
    echo "this script.  Instructions can be found here:"
    echo "    https://developers.yubico.com/yubikey-manager/"
    exit 1
elif [[ -z ${1+x} ]] || [[ ! -r $1 ]]; then
    echo "File does not exist, or is unreadable, or not provided."
    exit 1
fi

echo "You are about to install OATH/TOTP tokens onto the yubikey."
echo "Doing so will ERASE ALL CURRENT tokens, including any Windows"
echo "Hello keys, and REPLACE them."
echo ""
echo "THIS CANNOT BE UNDONE!  Please review these keys before"
echo "continuing:"

"${YKMAN_BIN}" oath accounts list -H -o

read -p "Are you sure you want to continue? " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Erasing your current OATH tokens..."
    "${YKMAN_BIN}" oath reset --force

    # Set IFS to '\r\n' to handle Windows line endings
    while IFS=$'\n' read -r line; do
        if [[ ${line:0:1} != "#" ]]; then
            s=${line//[$'\t\r\n ']}$DELIMITER
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
                
                # If $TOUCH_TRUE is set OR if FORCE_TOUCH is set,
                # then enable touch.
                if [[ $TOUCH_TRUE == "t" ]] || [[ $FORCE_TOUCH == "t" ]]; then
                    FLAGS="${FLAGS} --touch"
                fi

                # If there are options set, then append them here
                if [[ ! -z $OPTIONS && ${OPTIONS+x} ]]; then
                    echo "Adding options: (${OPTIONS})"
                    FLAGS="${FLAGS} ${OPTIONS}"
                fi

                # If $ISSUER is set, then add it
                if [[ ! -z $ISSUER && ${ISSUER+x} ]]; then
                    FLAGS="${FLAGS} --issuer ${ISSUER}"
                fi

                "${YKMAN_BIN}" oath accounts add \
                    ${FLAGS} \
                    "${ACCOUNT}" \
                    "${SECRET}"

                if [[ $? == 0 ]]; then
                    echo "Successfully added: ${ISSUER} ${ACCOUNT}"
                else
                    echo "FAILED to add: ${ISSUER} ${ACCOUNT}"
                fi 
            fi
        fi
    done < "${1}"
fi
