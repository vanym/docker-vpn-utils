#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")

CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps route -q --status running)
CIP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CID")
NAME=$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' "$CID")

HEXID='5'$(echo -n "$NAME" | md5sum | cut -f1 -d' ' | cut -c1-6)
DECID=$((16#$HEXID))

mount --bind -o ro "$DIRSH"/resolv.conf /etc/resolv.conf
ip route add default via "$CIP" table "$DECID"
ip rule add from all suppress_prefixlength 0 priority 30100
ip rule add from all table "$DECID" priority 30101
