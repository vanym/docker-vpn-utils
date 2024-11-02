#!/bin/bash

set -e

NETNS="route"

mkdir -p /var/run/netns
[ -e /var/run/netns/"$NETNS" ] || \
  ln -s /proc/1/ns/net /var/run/netns/"$NETNS"

cat_wgquick_modded(){
  sed '/~~ function override insertion point ~~/ { s/^.*$/\
add_if() {\
  cmd ip link set dev '"${1}"' name "$INTERFACE"\
}\
\
add_default() {\
  local proto=-4\
  [[ $1 == *:* ]] \&\& proto=-6\
  cmd ip $proto route add "$1" dev "$INTERFACE"\
}\
\
&/}' "$(which wg-quick | head -1)"
}

IFS=$'\n'
CONFS=($(find /etc/wireguard -maxdepth 1 -name '*.conf' -xtype f))
trap 'for CONF in "${CONFS[@]}"; do ip netns exec "$NETNS" wg-quick down "$CONF"; done' EXIT
for CONF in "${CONFS[@]}"; do
  INTERFACE="wg$(xxd -l 3 -p /dev/urandom)"
  ip link add "$INTERFACE" type wireguard
  ip link set "$INTERFACE" netns "$NETNS"
  ip netns exec "$NETNS" bash <(cat_wgquick_modded "$INTERFACE") up "$CONF"
done

sleep inf
