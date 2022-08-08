#!/bin/bash

function cert_info() {
    local domain=$1
    local host=${domain%%:*}
    local port=${domain##*:}
    local paddingdays=$2
    local secs=$[86400 * $paddingdays]

    #echo $host' / '$port
    echo | openssl s_client -servername $host -connect $host:$port 2>&1 | openssl x509 -inform pem -dates -checkend $secs
}

function cert_verify() {
    local rtn=0
    local domain=$1
    local host=${domain%%:*}
    local port=${domain##*:}
    local paddingdays=$2
    local info=''
    local chk=''

    local mail_from=$3
    local mail_to=$4
    local mail_subject=''

    local cert_issuer=$(dirname $(realpath $0))/cert-issuer.sh

    info=$(cert_info $domain $paddingdays)
    chk=$(echo -e "$info" | grep 'will expire')

    if [ ! -z "$chk" ]; then
        ####################### mail-notify : near by expiration
        if [ $rtn -eq 0 ]; then
            mail_subject="SSL Certificate [$host] will be expired within $paddingdays days"
            send_mail "$mail_from" "$mail_to" "$mail_subject" "$info"
            if [ $? -eq 0 ]; then
                # success send mail for expiration
                rtn=1
            fi
        fi

        ####################### issue
        if [ $rtn -eq 1 ]; then
            source $cert_issuer "$host" "$mail_to"
            if [ $? -eq 0 ]; then
                # success issued new certification
                rtn=2
            fi
        fi

        ####################### mail-notify : issued successfully
        if [ $rtn -eq 2 ]; then
            # enough paddingdays
            info=$(cert_info $domain 365)
            mail_subject="SSL Certificate [$host] has been issued"
            send_mail "$mail_from" "$mail_to" "$mail_subject" "$info"
            if [ $? -eq 0 ]; then
                # success send mail for issued
                rtn=3
            fi
        fi
    else
        echo "$host : not yet"
    fi

    return $rtn
}

function send_mail() {
    local expire_from=''
    local expire_to=''

    local mail_from=$1
    local mail_to=$2
    local mail_from_header="From: Domain SSL Management Bot <$mail_from>"
    local mail_subject=$3
    local mail_content=''
    local mail_content_header='Content-Type: text/html; charset=UTF-8'

    local info=$4

    expire_from=$(echo -e "$info" | grep 'notBefore' | sed 's/notBefore=//')
    expire_to=$(echo -e "$info" | grep 'notAfter' | sed 's/notAfter=//')
    mail_content=''
    mail_content=$mail_content"Valid period information\n"
    mail_content=$mail_content"from: $expire_from\n"
    mail_content=$mail_content"to  : $expire_to\n"
    mail_content='<pre>'$mail_content'</pre>'

    echo -e "$mail_content" | mail -a "$mail_from_header" -a "$mail_content_header" -s "$mail_subject" "$mail_to"
}

##################################################
#         domainset=domain:port,paddingdays,mail_from,mail_to
#         domainsets="domainset;domainset;..."
#    e.g. domainsets="bar.com:443,14,bot@bar.com,foo@bar.com;baz.com:443,14,bot@baz.com,foo@baz.com;..."
#
# e.g. single execution
# ./cert-verifier.sh "bar.com:443,14,bot@bar.com,foo@bar.com"
# /usr/local/bin/cert-verifier.sh "bar.com:443,14,bot@bar.com,foo@bar.com"
#
# e.g. crontab execution
# 0 0 * * * /usr/local/bin/cert-verifier.sh "bar.com:443,14,bot@bar.com,foo@bar.com"
# 0 0 * * * /usr/local/bin/cert-verifier.sh "bar.com:443,14,bot@bar.com,foo@bar.com" > /var/log/syslog 2>&1
##################################################
function main() {
    local domainsets=(${1//;/ })
    local domainset=''
    local each_domain=''
    local each_paddingdays=''
    local each_mail_from=''
    local each_mail_to=''
    local i=''
    local chk=0

    for i in "${domainsets[@]}"
    do
        domainset=(${i//,/ })
        each_domain=${domainset[0]}
        each_paddingdays=${domainset[1]}
        each_mail_from=${domainset[2]}
        each_mail_to=${domainset[3]}
        #echo $each_domain $each_paddingdays $each_mail_from $each_mail_to
        cert_verify "$each_domain" "$each_paddingdays" "$each_mail_from" "$each_mail_to"

        #chk=$?
        #echo 'domain: '$each_domain
        #echo 'chk: '$chk
    done

    return 0
}

main $1
