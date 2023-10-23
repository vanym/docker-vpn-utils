#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")

ip2dec(){ declare -i a b c d; IFS=. read a b c d <<<"$*"; echo "$(((a<<24)+(b<<16)+(c<<8)+d))"; }
dec2ip(){ declare -i m=$((0xff)) n="$1"; echo "$((n>>24&m)).$((n>>16&m)).$((n>>8&m)).$((n&m))"; }

HOSTRANGE=$(cat "$DIRSH"/config/address)
HOSTIP=$(echo "$HOSTRANGE" | cut -d '/' -f 1)
HOSTIPDEC=$(ip2dec "$HOSTIP")
HOSTPUBKEY=$(cat "$DIRSH"/config/publickey)

export -f ip2dec dec2ip
HIGHIPDEC=$({ echo "$HOSTIPDEC" ; grep -hRPo "AllowedIPs = \K.*" "$DIRSH"/config --include=peer*.conf | cut -d '/' -f 1 | xargs -r -n1 bash -c 'ip2dec "${@}"' _ ; } | sort -n | tail -1)
PEERIPDEC=$((HIGHIPDEC+1))
PEERIP=$(dec2ip "$PEERIPDEC")

PRIVATEKEY=$(wg genkey)
PUBLICKEY=$(echo "$PRIVATEKEY" | wg pubkey)

cat <<-EOF
[Interface]
PrivateKey = $PRIVATEKEY
Address = $PEERIP
DNS = $HOSTIP

[Peer]
PublicKey = $HOSTPUBKEY
AllowedIPs = $HOSTRANGE, 0.0.0.0/0
#Endpoint = 
EOF

CONF=$(printf 'peer%02d.conf\n' $((PEERIPDEC-HOSTIPDEC)))

cat > "$DIRSH"/config/"$CONF" <<-EOF
[Peer]
PublicKey = $PUBLICKEY
AllowedIPs = $PEERIP/32
EOF
