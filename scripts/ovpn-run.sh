#!/bin/bash

set -e

NETNS="route"

mkdir -p /var/run/netns
ln -sf /proc/1/ns/net /var/run/netns/"$NETNS"

exec openvpn \
  --ifconfig-noexec \
  --route-noexec \
  --script-security 2 \
  --setenv NETNS "$NETNS" \
  --setenv DNS "1" \
  --setenv IPV6 "1" \
  --up "/opt/scripts/ovpn-hook.sh" \
  --route-up "/opt/scripts/ovpn-hook.sh" \
  --route-pre-down "/opt/scripts/ovpn-hook.sh" \
  --down "/opt/scripts/ovpn-hook.sh" \
  --cd /etc/openvpn \
  --config ovpn.conf \
  "${@}"
