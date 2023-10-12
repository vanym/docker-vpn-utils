#!/bin/bash

set -e

SCREEN_NAME="piaport-run"

# bypass https://savannah.gnu.org/bugs/?55618
[ $(ulimit -n) -le 1024 ] || ulimit -n 1024

case $script_type in
  route-up)
    { read -r PIA_USER && read -r PIA_PASS ; } < login.conf
    export PIA_USER PIA_PASS
    export PF_GATEWAY="$route_vpn_gateway"
    export PF_HOSTNAME="$X509_0_CN"
    export DEV="$dev"
    pushd /opt/scripts > /dev/null
    [ -f piaport/get_token.sh -a -f piaport/port_forwarding.sh ] || \
      echo "WARNING: can't find piaport scripts"
    ip netns exec "$NETNS" screen -dmS "$SCREEN_NAME" ./ovpn-piaport-run.sh
    popd > /dev/null
  ;;
  route-pre-down)
    screen -S "$SCREEN_NAME" -X quit
  ;;
esac
