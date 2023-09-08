# syntax=docker/dockerfile:1.4

FROM alpine:3 AS image

ENV PATH="/opt/ddns-cloudflare:$PATH"
WORKDIR /opt/ddns-cloudflare

ARG cache_date
RUN apk update && \
	apk upgrade --no-cache --no-interactive && \
	apk add --no-cache --no-interactive bash curl findutils jq ssmtp

COPY --link --chmod=544 docker/build/entrypoint.sh ddns-cloudflare ./

RUN mkdir -m 755 /default && \
	mkdir -m 755 /default/etc && \
	mkdir -m 755 /default/var && \
	mkdir -m 755 /default/var/spool && \
	mkdir -m 755 /container && \
	mv /etc/crontabs /default/etc/crontabs && ln -s /container/etc/crontabs /etc/crontabs && \
	mv /etc/ssmtp /default/etc/ssmtp && ln -s /container/etc/ssmtp /etc/ssmtp && \
	mv /var/spool/cron /default/var/spool/cron && ln -s /container/var/spool/cron /var/spool/cron && \
	ln -s /container/etc/localtime /etc/localtime && \
	mkdir -m 755 /etc/opt && \
	mkdir -m 755 /etc/opt/ddns-cloudflare && \
	touch /etc/timezone && chmod 644 /etc/timezone

# tmpfs
VOLUME /etc/crontabs
VOLUME /etc/ssmtp
VOLUME /var/spool/cron

# bind
VOLUME /etc/opt/ddns-cloudflare
VOLUME /etc/ssmtp/ssmtp.conf
VOLUME /etc/timezone

ENTRYPOINT ["entrypoint.sh"]
