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
