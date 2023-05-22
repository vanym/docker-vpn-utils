#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")

CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps route -q --status running)
CIP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CID")
NAME=$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' "$CID")

HEXID='5'$(echo -n "$NAME" | md5sum | cut -f1 -d' ' | cut -c1-6)
DECID=$((16#$HEXID))

umount /etc/resolv.conf
ip route flush table "$DECID"
ip rule del from all suppress_prefixlength 0 priority 30100
ip rule del from all table "$DECID" priority 30101
