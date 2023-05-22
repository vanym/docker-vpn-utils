#!/bin/bash

set -e

DIRSH=$(dirname "${BASH_SOURCE[0]}")
NSNAME=$("$DIRSH"/addnetns.sh)
exec ip netns exec "$NSNAME" unshare -- "${@}"
