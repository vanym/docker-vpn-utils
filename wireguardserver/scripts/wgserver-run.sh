#!/bin/bash

set -e

NETNS="route"

mkdir -p /var/run/netns
[ -e /var/run/netns/"$NETNS" ] || \
  ln -s /proc/1/ns/net /var/run/netns/"$NETNS"

INTERFACE="${INTERFACE:-wg$(xxd -l 3 -p /dev/urandom)}"
ADDRESS=$(cat /etc/wireguard/address)
LISTENPORT=$(cat /etc/wireguard/wgport)

ip link add "$INTERFACE" type wireguard
trap "ip -n $NETNS link del $INTERFACE" EXIT
ip link set "$INTERFACE" netns "$NETNS"
ip -n "$NETNS" address add dev "$INTERFACE" "$ADDRESS"

ip netns exec route wg set "$INTERFACE" listen-port "$LISTENPORT" private-key /etc/wireguard/privatekey
find /etc/wireguard -name '*.conf' -maxdepth 1 -type f -size +0 | \
  ip netns exec route xargs -d '\n' -r -n1 wg addconf "$INTERFACE"

ip -n "$NETNS" link set up dev "$INTERFACE"

sleep inf
