FROM busybox:1.37.0-uclibc as busybox

FROM gcr.io/distroless/base-debian11

COPY --from=busybox /bin/sh /bin/sh
COPY --from=busybox /bin/mkdir /bin/mkdir
COPY --from=busybox /bin/cat /bin/cat

FROM caddy:2.10.0-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/greenpau/caddy-security

FROM caddy:2.10.0

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY signal_handler.sh /
RUN chmod +x /signal_handler.sh
CMD ["/signal_handler.sh", "caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
