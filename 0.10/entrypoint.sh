#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi

if [ "$1" = 'telegraf' ]; then
    set -- "$@"
fi

if [ "$( echo $@ | grep "\-config /etc/telegraf/telegraf.conf")" != "" ]; then
    # Print the config file without the comments
    separatorLine="-------------------------------------------------"
    echo -e $separatorLine'\n'"Using Default Config"'\n'$separatorLine 
    sed -e  's/^\ *#.*//' /etc/telegraf/telegraf.conf | awk '{if (NF > 0) print $0}'
    echo $separatorLine
fi

exec "$@"
