#!/bin/sh

dnsmasq --no-poll --log-facility=/proc/$$/fd/1 "${@}" -r /etc/resolv.conf
PID=$(cat /run/dnsmasq.pid)
inotifywait -qm -e close_write /etc/resolv.conf | tee /proc/$$/fd/1 | \
  while read; do kill -SIGHUP "$PID"; done
