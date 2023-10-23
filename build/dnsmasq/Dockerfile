FROM alpine:3.18
RUN apk add --no-cache dnsmasq inotify-tools
COPY entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
