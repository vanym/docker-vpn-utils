#!/bin/bash

set -e

pushd piaport > /dev/null
trap 'popd > /dev/null' EXIT

if ! read -r PIA_TOKEN_EXPIRE < <(tail -1 /opt/piavpn-manual/token) || \
   ! [ $(($(date --date="$PIA_TOKEN_EXPIRE" +%s) - $(date +%s))) -gt 60 ] ; then
  ./get_token.sh 1>&2
fi

read -r PIA_TOKEN < /opt/piavpn-manual/token
export PIA_TOKEN

./port_forwarding.sh | grep --line-buffered "Forwarded port" | grep --line-buffered -E -o "[0-9]+"
