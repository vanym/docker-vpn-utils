#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")
CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps route -q)
NSPATH=$(docker inspect -f '{{ .NetworkSettings.SandboxKey }}' "$CID")
NSNAME=${1:-$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' "$CID")}

rm -f /var/run/netns/"$NSNAME"
rm -rf /etc/netns/"$NSNAME"
echo "$NSNAME"
