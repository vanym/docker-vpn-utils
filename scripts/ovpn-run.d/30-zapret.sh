#!/bin/bash

ZAPRET_QNUM="${ZAPRET_QNUM:-200}"
ZAPRET_FWMARK="${ZAPRET_FWMARK:-0x40000000}"
ZAPRET_CGROUP_PATH="${ZAPRET_CGROUP_PATH:-/}"
ZAPRET_MATCH="${ZAPRET_MATCH}"
if iptables -t mangle -N ZAPRET-"$ZAPRET_QNUM"; then
  iptables -t mangle -I POSTROUTING ! -o lo -j ZAPRET-"$ZAPRET_QNUM"
fi
iptables -t mangle -F ZAPRET-"$ZAPRET_QNUM"
iptables -t mangle -A ZAPRET-"$ZAPRET_QNUM" \
  -m cgroup --path "$ZAPRET_CGROUP_PATH" \
  -m mark ! --mark "$ZAPRET_FWMARK"/"$ZAPRET_FWMARK" \
  ${ZAPRET_MATCH} \
  -j NFQUEUE --queue-num "$ZAPRET_QNUM"
