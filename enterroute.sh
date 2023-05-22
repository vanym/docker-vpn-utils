#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")

CGROUP_PARENT=$(grep '0::' /proc/$$/cgroup | cut -f 3- -d:)

CGROUP_ROOT="/sys/fs/cgroup"
[ -f "$CGROUP_ROOT"/cgroup.procs ] || CGROUP_ROOT="/sys/fs/cgroup/unified"
[ -f "$CGROUP_ROOT"/cgroup.procs ] || CGROUP_ROOT="$(mount -t cgroup2 | head -n1 | grep -oP '^cgroup2 on \K\S+')"

CID=$(docker-compose -f "$DIRSH"/docker-compose.yml ps route -q --status running)
CIP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CID")
NAME=$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' "$CID")
BASENAME=route."$NAME"

if [ "${CGROUP_PARENT##*/}" != "$BASENAME" ]; then
  CGROUP_NAME="$CGROUP_PARENT"/"$BASENAME"
else
  CGROUP_NAME="$CGROUP_PARENT"
fi
HEXID='4'$(echo -n "$CGROUP_NAME" | md5sum | cut -f1 -d' ' | cut -c1-6)
DECID=$((16#$HEXID))

if mkdir "$CGROUP_ROOT"/"$CGROUP_NAME" 2> >(:); then
  iptables -t mangle -A OUTPUT -m cgroup --path "$CGROUP_NAME" -j MARK --set-mark "$DECID"
  iptables -t nat -A POSTROUTING -m mark --mark "$DECID" -j MASQUERADE
  ip route add default via "$CIP" table "$DECID"
  ip rule add fwmark "$DECID" table "$DECID" priority 20101
  ip rule add fwmark "$DECID" suppress_prefixlength 0 priority 20100
  systemd-run -q bash -c '
#!/bin/bash

set -e

CGROUP_ROOT="$1"
CGROUP_NAME="$2"
DECID="$3"

while grep "populated 1" "$CGROUP_ROOT"/"$CGROUP_NAME"/cgroup.events && \
      inotifywait -e MODIFY "$CGROUP_ROOT"/"$CGROUP_NAME"/cgroup.events
do true ; done

iptables -t mangle -D OUTPUT -m cgroup --path "$CGROUP_NAME" -j MARK --set-mark "$DECID"
iptables -t nat -D POSTROUTING -m mark --mark "$DECID" -j MASQUERADE
ip route flush table "$DECID"
ip rule del fwmark "$DECID" suppress_prefixlength 0 priority 20100
ip rule del fwmark "$DECID" table "$DECID" priority 20101
rmdir "$CGROUP_ROOT"/"$CGROUP_NAME"

' _ "$CGROUP_ROOT" "$CGROUP_NAME" "$DECID"
fi

echo $$ > "$CGROUP_ROOT"/"$CGROUP_NAME"/cgroup.procs
exec unshare -m --propagation slave bash -c 'mount --make-private --bind -o ro "'"$DIRSH"/resolv.conf'" /etc/resolv.conf && exec unshare "${@}"' _ "${@}"
