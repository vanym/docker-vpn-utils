#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")

PRIVATEKEY="$DIRSH"/config/privatekey
PUBLICKEY="$DIRSH"/config/publickey

echo -n "PublicKey = "
wg genkey | (umask 077; tee "$PRIVATEKEY") | wg pubkey | tee "$PUBLICKEY"
