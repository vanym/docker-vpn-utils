#!/bin/bash

set -e

PIA_LOCAL_HOST=${PIA_LOCAL_HOST}
PIA_LOCAL_PORT=${PIA_LOCAL_PORT:-9011}
DEV="${DEV:-tun0}"

add_network_rules(){
  local DEV="$1"
  local LOCALHOST="$2"
  local LOCALPORT="$3"
  local REMOTEPORT="$4"
  iptables -t nat -N PIAPORT-PREROUTING
  iptables -t nat -A PREROUTING -i "$DEV" -j PIAPORT-PREROUTING
  iptables -t nat -A PIAPORT-PREROUTING -p tcp --dport "$REMOTEPORT" -j DNAT --to "$LOCALHOST":"$LOCALPORT"
  iptables -t nat -A PIAPORT-PREROUTING -p udp --dport "$REMOTEPORT" -j DNAT --to "$LOCALHOST":"$LOCALPORT"
  iptables -t nat -A PIAPORT-PREROUTING -p tcp --dport "$LOCALPORT" -j REDIRECT --to-port "$REMOTEPORT"
  iptables -t nat -A PIAPORT-PREROUTING -p udp --dport "$LOCALPORT" -j REDIRECT --to-port "$REMOTEPORT"

  iptables -t nat -N PIAPORT-POSTROUTING
  iptables -t nat -A POSTROUTING -o "$DEV" -j PIAPORT-POSTROUTING
  iptables -t nat -A PIAPORT-POSTROUTING -p tcp --sport "$LOCALPORT" -j SNAT --to :"$REMOTEPORT"
  iptables -t nat -A PIAPORT-POSTROUTING -p udp --sport "$LOCALPORT" -j SNAT --to :"$REMOTEPORT"
  iptables -t nat -A PIAPORT-POSTROUTING -p tcp --sport "$REMOTEPORT" -j SNAT --to :"$LOCALPORT"
  iptables -t nat -A PIAPORT-POSTROUTING -p udp --sport "$REMOTEPORT" -j SNAT --to :"$LOCALPORT"
}

delete_network_rules(){
  local DEV="$1"
  set +e
  iptables -t nat -F PIAPORT-PREROUTING
  iptables -t nat -D PREROUTING -i "$DEV" -j PIAPORT-PREROUTING
  iptables -t nat -X PIAPORT-PREROUTING
  iptables -t nat -F PIAPORT-POSTROUTING
  iptables -t nat -D POSTROUTING -o "$DEV" -j PIAPORT-POSTROUTING
  iptables -t nat -X PIAPORT-POSTROUTING
  set -e
} 2> /dev/null

bind_loop(){
  while true; do
    ./ovpn-piaport-bind.sh
    echo 0
    sleep 20
  done
}

handle_ports(){
  while read -r PORT ; do
    delete_network_rules "$DEV"
    if (($PORT)) ; then
      add_network_rules "$DEV" "$PIA_LOCAL_HOST" "$PIA_LOCAL_PORT" "$PORT"
    fi
  done
}

trap 'delete_network_rules "$DEV"' EXIT

bind_loop | stdbuf -i0 -o0 -e0 uniq | handle_ports
