#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")

CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps openvpn -q --status running)
CIP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CID")

ip rule add from "$CIP" priority 30000
