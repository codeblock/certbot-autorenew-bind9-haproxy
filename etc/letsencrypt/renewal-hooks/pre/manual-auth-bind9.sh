#!/bin/bash

. ../common/includes.sh

########################################################################
# # source
# echo '<<< pre >>>'
# echo 'CERTBOT_DOMAIN: '$CERTBOT_DOMAIN
# echo 'CERTBOT_VALIDATION: '$CERTBOT_VALIDATION
# echo 'CERTBOT_TOKEN: '$CERTBOT_TOKEN
# echo 'CERTBOT_REMAINING_CHALLENGES: '$CERTBOT_REMAINING_CHALLENGES
# echo 'CERTBOT_ALL_DOMAINS: '$CERTBOT_ALL_DOMAINS

# # output
# <<< pre >>>
# CERTBOT_DOMAIN: example.com
# CERTBOT_VALIDATION: n4KpaVKLkpcuXt1W-z0-OENGbMUvI5cEB07dWvBDeNA
# CERTBOT_TOKEN:
# CERTBOT_REMAINING_CHALLENGES: 0
# CERTBOT_ALL_DOMAINS: example.com,example.com
########################################################################

# append the TXT Record to zone file, BIND Domain Name Server reload
function main() {
    local record=$(get_record_txt $CERTBOT_DOMAIN $CERTBOT_VALIDATION)
    local filepath=$(get_filepath_zone $CERTBOT_DOMAIN)
    echo $record >> $filepath
    service bind9 reload
}

main
