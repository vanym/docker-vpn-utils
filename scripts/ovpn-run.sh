#!/bin/bash

set -e

NETNS="route"

mkdir -p /var/run/netns
ln -sf /proc/1/ns/net /var/run/netns/"$NETNS"

source /opt/scripts/ovpn-run-rr.sh
mkdir -p /opt/rr
rr_rotate /opt/rr/always /etc/openvpn/rr/always.d/

exec openvpn \
  --ifconfig-noexec \
  --route-noexec \
  --script-security 2 \
  --setenv NETNS "$NETNS" \
  --setenv DNS "1" \
  --setenv IPV6 "" \
  --up "/opt/scripts/ovpn-hook.sh" \
  --route-up "/opt/scripts/ovpn-hook.sh" \
  --route-pre-down "/opt/scripts/ovpn-hook.sh" \
  --down "/opt/scripts/ovpn-hook.sh" \
  --cd /etc/openvpn \
  --config ovpn.conf \
  "${@}"
