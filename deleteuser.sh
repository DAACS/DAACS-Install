#!/bin/bash 

username=$1
if [ "$username" = "root" ]; then

    echo "You can't do that"
    exit 1
fi

if [ -z "$1" ]; 
then 
echo "NULL"; 
else 
    # echo "Not NULL: ${1}"; 
userdel "${1}" && rm -fr "/home/${1}" 
fi
