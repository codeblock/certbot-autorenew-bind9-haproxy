# certbot-autorenew-bind9-haproxy

Automatic Renew the wildcard domain SSL Certificate on BIND 9 and HAProxy with Certbot

without ~~[Certbot DNS Plugins](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins)~~

on self-managed Domain Name Server

## Notice

-   Each \*.sh script need a execution permission (0755)
-   Tested all applications in one Server (may be changed on your needs)
-   You may need to modify service, commands, service names, and paths to suit your needs (`/etc/letsencrypt/renewal-hooks/common/includes.sh`)
    -   `/var/cache/bind/db.$domain.zone`
    -   `/etc/haproxy/certs/fullchain.pem`
    -   `service haproxy reload`
    -   `service bind9 reload`

## Requirements

-   Need a `root` permission
-   application
    -   `BIND 9`
    -   `HAProxy`
    -   `certbot`
    -   mailutils for `mail` command (and SMTP configuration when it needs)

## How it works

1. run `/usr/local/bin/cert-verifier.sh` with parameters
2. Be executed `certbot` command by `/usr/local/bin/cert-issuer.sh` when it needs
3. `certbot` calls each script by their own step

    1. `/etc/letsencrypt/renewal-hooks/pre/manual-auth-bind9.sh`
        - fetch and append TXT record to zone file of domain after the certbot's dns-challenge
        - certbot be reading it after reloading bind9 for applying that
    2. `/etc/letsencrypt/renewal-hooks/post/manual-cleanup-bind9.sh`
        - revert the appended TXT record from zone file of domain
    3. `/etc/letsencrypt/renewal-hooks/deploy/deploy-haproxy.sh`
        - copy the created key file to haproxy configuration directory (OR other Load Balancer OR other Server that reads key file)
        - reloading haproxy (OR other Load Balancer OR other Server that reads key file)
        - reloading bind9

## Structure

```
├── etc
│   └── letsencrypt
│       └── renewal-hooks
│           ├── common
│           │   └── includes.sh
│           ├── deploy
│           │   └── deploy-haproxy.sh
│           ├── post
│           │   └── manual-cleanup-bind9.sh
│           └── pre
│               └── manual-auth-bind9.sh
└── usr
    └── local
        └── bin
            ├── cert-issuer.sh
            └── cert-verifier.sh

```

## Parameters

domainset=domain:port`,`paddingdays`,`mail_from`,`mail_to

domainsets="domainset`;`domainset`;`..."

domainsets="bar.com:443`,`14`,`bot@bar.com`,`foo@bar.com`;`baz.com:443`,`14`,`bot@baz.com`,`foo@baz.com`;`..."

## Examples

### single execution : two domainsets, before 365 day from expiration

```bash
$              ./cert-verifier.sh "bar.com:443,365,bot@bar.com,foo@bar.com;baz.com:443,365,bot@baz.com,foo@baz.com"
```

### single execution : one domainset, before 30 day from expiration

```bash
$ /usr/local/bin/cert-verifier.sh "bar.com:443,30,bot@bar.com,foo@bar.com"
```

### crontab execution : two domainsets, before 20 day from expiration, on 0 o'clock

```bash
$ crontab -e
$ 0 0 * * * /usr/local/bin/cert-verifier.sh "bar.com:443,20,bot@bar.com,foo@bar.com;baz.com:443,20,bot@baz.com,foo@baz.com"
```

### crontab execution : one domainset, before 14 day from expiration, stdout/stderr to /var/log/syslog on 0 o'clock

```bash
$ crontab -e
$ 0 0 * * * /usr/local/bin/cert-verifier.sh "bar.com:443,14,bot@bar.com,foo@bar.com" > /var/log/syslog 2>&1
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Donation

If this project help you reduce time to develop, you can give me a cup of coffee :)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/windows)

## License

[MIT](https://choosealicense.com/licenses/mit/)
