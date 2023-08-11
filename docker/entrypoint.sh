#!/bin/sh

cp -a /etc/default-crontabs/* /etc/crontabs

crontab="MAILFROM=$MAIL_FROM"
crontab="$crontab\nMAILTO=$MAIL_TO"
crontab="$crontab\n*/$DDNS_CLOUDFLARE_PERIOD * * * * /opt/ddns-cloudflare/ddns-cloudflare $@"
echo -e "$crontab" >> /etc/crontabs/root

crond -f -l 4
