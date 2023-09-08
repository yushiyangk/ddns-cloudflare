#!/bin/sh

# Restore writeable files
cp -a /default/* /container

# Set time zone
ln -s /usr/share/zoneinfo/"$(cat /etc/timezone)" /container/etc/localtime


echo "root:ddns-cloudflare@$MAIL_DOMAIN" > /etc/ssmtp/revaliases

crontab="MAILTO=$MAIL_TO"
crontab="$crontab\n*/$DDNS_CLOUDFLARE_INTERVAL_MINS * * * * /opt/ddns-cloudflare/ddns-cloudflare $@"
echo -e "$crontab" >> /etc/crontabs/root

crond -f -l 4
