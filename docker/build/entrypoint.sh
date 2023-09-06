#!/bin/sh

# Restore writeable volumes
cp -a /etc/default-crontabs/* /etc/crontabs
cp -a /var/spool/default-cron/* /var/spool/cron


echo "root:ddns-cloudflare@$MAIL_DOMAIN" > /etc/ssmtp/revaliases

crontab="MAILTO=$MAIL_TO"
crontab="$crontab\n*/$DDNS_CLOUDFLARE_INTERVAL_MINS * * * * /opt/ddns-cloudflare/ddns-cloudflare $@"
echo -e "$crontab" >> /etc/crontabs/root

crond -f -l 4
