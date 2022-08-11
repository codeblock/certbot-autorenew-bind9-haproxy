#!/bin/bash

. $(dirname $(dirname $(realpath $0)))/common/includes.sh

########################################################################
# # source
# echo '<<< post >>>'
# echo 'CERTBOT_DOMAIN: '$CERTBOT_DOMAIN
# echo 'CERTBOT_VALIDATION: '$CERTBOT_VALIDATION
# echo 'CERTBOT_TOKEN: '$CERTBOT_TOKEN
# echo 'CERTBOT_REMAINING_CHALLENGES: '$CERTBOT_REMAINING_CHALLENGES
# echo 'CERTBOT_ALL_DOMAINS: '$CERTBOT_ALL_DOMAINS

# # output
# <<< post >>>                                                   
# CERTBOT_DOMAIN: example.com                                       
# CERTBOT_VALIDATION: Fm8WRwI8zic-mUsjBwkV5wuFdyWP25sraJV37ek5ZZQ
# CERTBOT_TOKEN:                                                 
# CERTBOT_REMAINING_CHALLENGES: 0                                
# CERTBOT_ALL_DOMAINS: example.com,example.com                       
########################################################################

# remove the appended lines just before from zone file
function main() {
    local record=$(get_record_txt $CERTBOT_DOMAIN $CERTBOT_VALIDATION)
    local filepath=$(get_filepath_zone $CERTBOT_DOMAIN)
    sed -i "/$record/d" $filepath
}

main
