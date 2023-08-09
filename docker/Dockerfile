FROM alpine:3 AS image

ENV PATH="/opt/ddns-cloudflare:$PATH"
WORKDIR /opt/ddns-cloudflare

ARG cache_date
RUN apk update && \
	apk upgrade --no-cache --no-interactive && \
	apk add --no-cache --no-interactive bash curl findutils jq ssmtp

RUN mkdir -p /etc/default-crontabs && \
	mv /etc/crontabs/* /etc/default-crontabs

COPY --link docker/entrypoint.sh /usr/bin/entrypoint.sh
COPY --link ddns-cloudflare ddns-cloudflare

# tmpfs
VOLUME /etc/crontabs

# bind
VOLUME /etc/opt/ddns-cloudflare
VOLUME /etc/ssmtp/ssmtp.conf

# ddns-cloudflare-state
VOLUME /tmp

ENTRYPOINT ["entrypoint.sh"]
