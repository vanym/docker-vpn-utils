#!/bin/bash

DIRSH=$(dirname "${BASH_SOURCE[0]}")

exec sudo -E "$DIRSH"/enterns.sh sudo -E -s -u "$(id -u -n)" -g "$(id -g -n)" -- "${@}"
