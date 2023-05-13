#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")
CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps route -q)
PID=$(docker inspect -f '{{ .State.Pid }}' "$CID")

exec unshare -m bash -c 'mount --make-private --bind "'"$DIRSH"/resolv.conf'" /etc/resolv.conf && exec nsenter -t "$0" -n "${@}"' "$PID" "${@}"
