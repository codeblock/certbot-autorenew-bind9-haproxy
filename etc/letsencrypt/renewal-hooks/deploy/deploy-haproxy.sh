#!/bin/bash

########################################################################
# # source
# echo '<<< deploy >>>'
# echo 'RENEWED_LINEAGE: '$RENEWED_LINEAGE
# echo 'CERTBOT_DOMAIN: '$CERTBOT_DOMAIN
# echo 'CERTBOT_VALIDATION: '$CERTBOT_VALIDATION
# echo 'CERTBOT_TOKEN: '$CERTBOT_TOKEN
# echo 'CERTBOT_REMAINING_CHALLENGES: '$CERTBOT_REMAINING_CHALLENGES
# echo 'CERTBOT_ALL_DOMAINS: '$CERTBOT_ALL_DOMAINS
# echo 'CERTBOT_AUTH_OUTPUT: '$CERTBOT_AUTH_OUTPUT

# # output
# <<< deploy >>>                
# RENEWED_LINEAGE: /etc/letsencrypt/live/example.com
# CERTBOT_DOMAIN:                
# CERTBOT_VALIDATION:           
# CERTBOT_TOKEN:                
# CERTBOT_REMAINING_CHALLENGES: 
# CERTBOT_ALL_DOMAINS:          
# CERTBOT_AUTH_OUTPUT:          
########################################################################

# copy the key file, HAProxy reload, BIND Domain Name Server reload(zone serial unchanged)
function main() {
    cat $RENEWED_LINEAGE/fullchain.pem $RENEWED_LINEAGE/privkey.pem > \
        /etc/haproxy/certs/fullchain.pem
    service haproxy reload
    service bind9 reload
}

main
