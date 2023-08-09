# syntax=docker/dockerfile:1.4

FROM debian:bookworm-slim AS fetch

WORKDIR /opt/ddns-cloudflare

ARG cache_date
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends curl unzip && \
	apt-get install -y --no-install-recommends ca-certificates && \
	# manual install of ca-certificates is required for platform linux/amd64
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://codeload.github.com/yushiyangk/ddns-cloudflare/zip/refs/heads/master -o ddns-cloudflare.zip && \
	unzip -t ddns-cloudflare.zip && unzip -j ddns-cloudflare.zip ddns-cloudflare-master/ddns-cloudflare && \
	chmod 550 ddns-cloudflare


FROM alpine:3 AS image

ENV PATH="/opt/ddns-cloudflare:$PATH"
WORKDIR /opt/ddns-cloudflare

ARG cache_date
RUN apk update && \
	apk upgrade --no-cache --no-interactive && \
	apk add --no-cache --no-interactive bash curl findutils jq ssmtp

RUN mkdir -p /etc/default-crontabs && \
	mv /etc/crontabs/* /etc/default-crontabs

COPY --link entrypoint.sh /usr/bin/entrypoint.sh
COPY --link --from=fetch /opt/ddns-cloudflare/ddns-cloudflare ddns-cloudflare

# tmpfs
VOLUME /etc/crontabs

# bind
VOLUME /etc/opt/ddns-cloudflare
VOLUME /etc/ssmtp/ssmtp.conf

# ddns-cloudflare-state
VOLUME /tmp

ENTRYPOINT ["entrypoint.sh"]
