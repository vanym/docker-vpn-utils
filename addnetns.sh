#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")
CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps route -q)
NSPATH=$(docker inspect -f '{{ .NetworkSettings.SandboxKey }}' "$CID")
NSNAME=${1:-$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' "$CID")}

mkdir -p /var/run/netns
ln -sf "$NSPATH" /var/run/netns/"$NSNAME"
mkdir -p /etc/netns/"$NSNAME"
ln -sf $(readlink -f "$DIRSH"/resolv.conf) /etc/netns/"$NSNAME"/resolv.conf
