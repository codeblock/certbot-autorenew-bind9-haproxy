#!/bin/bash

function get_record_txt() {
    local rtn=''
    local domain=$1
    local value=$2

    rtn="_acme-challenge.$domain. 300 IN TXT \"$value\""

    echo $rtn
}

function get_filepath_zone() {
    local rtn=''
    local domain=$1

    rtn="/var/cache/bind/db.$domain.zone"

    echo $rtn
}

function write_key() {
    local rtn=0
    local renewed_path=$1
    local target_path=/etc/haproxy/certs/fullchain.pem
    local suffix_backup=$(date +'%Y-%m-%dT%H-%M-%S%Z.pem')

    cat $renewed_path/fullchain.pem $renewed_path/privkey.pem > $target_path
    rtn=$?

    # backup
    if [ $rtn -eq 0 ]; then
        cp $target_path "${target_path}_${suffix_backup}"
    fi

    return $rtn
}

function reload_keyreader() {
    service haproxy reload
}

function reload_dns() {
    service bind9 reload
}
