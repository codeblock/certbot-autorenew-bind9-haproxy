#!/bin/bash

##################################################
# ./cert-issuer.sh bar.com foo@bar.com
##################################################
function main() {
    local domain=$1
    local email=$2

    # test mode arguments (Rate Limits : https://letsencrypt.org/docs/staging-environment/#rate-limits)
        #    --test-cert \
        #    --force-renewal \
        #    --break-my-certs \
    certbot certonly --manual \
        --agree-tos \
        --non-interactive \
        --quiet \
        --manual-auth-hook /etc/letsencrypt/renewal-hooks/pre/manual-auth-bind9.sh \
        --manual-cleanup-hook /etc/letsencrypt/renewal-hooks/post/manual-cleanup-bind9.sh \
        --deploy-hook /etc/letsencrypt/renewal-hooks/deploy/deploy-haproxy.sh \
        --preferred-challenges dns \
        -m "$email" \
        -d "*.$domain" -d "$domain"
}

main $1 $2
