# syntax=docker/dockerfile:1.4

FROM alpine:3 AS image

ENV PATH="/opt/ddns-cloudflare:$PATH"
WORKDIR /opt/ddns-cloudflare

ARG cache_date
RUN apk update && \
	apk upgrade --no-cache --no-interactive && \
	apk add --no-cache --no-interactive bash curl findutils jq ssmtp

COPY --link --chmod=544 docker/build/entrypoint.sh ddns-cloudflare ./

RUN mv /etc/crontabs /etc/default-crontabs && mkdir -m 755 /etc/crontabs && \
	mv /var/spool/cron /var/spool/default-cron && mkdir -m 755 /var/spool/cron

# tmpfs
VOLUME /etc/crontabs
VOLUME /etc/ssmtp
VOLUME /var/spool/cron

# bind
VOLUME /etc/opt/ddns-cloudflare
VOLUME /etc/ssmtp/ssmtp.conf

ENTRYPOINT ["entrypoint.sh"]
