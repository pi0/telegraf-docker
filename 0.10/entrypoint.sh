#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi

if [ "$1" = 'telegraf' ]; then
    set -- "$@"
fi

if [ "$( echo $@ | grep "\-config /etc/telegraf/telegraf.conf")" != "" ]; then
    if [ -n "$INFLUXDB_HOST" ]; then
        sed -e "s/urls = \[\"http:\/\/localhost:8086\"\]/urls = \[\"http:\/\/$INFLUXDB_HOST:8086\"\]/" /etc/telegraf/telegraf.conf > /etc/telegraf/telegraf.conf.tmp
        mv /etc/telegraf/telegraf.conf.tmp /etc/telegraf/telegraf.conf
    fi
    separatorLine="-------------------------------------------------"
    echo -e $separatorLine'\n'"Using Default Config"'\n'$separatorLine 
    sed -e  's/^\ *#.*//' /etc/telegraf/telegraf.conf | awk '{if (NF > 0) print $0}'
    echo $separatorLine
fi

exec "$@"
