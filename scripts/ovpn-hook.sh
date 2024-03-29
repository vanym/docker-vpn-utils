#!/bin/bash

ARGS=()
for ARG in "${@}"; do
  ARGS=("${ARGS[@]}" -a "${ARG}")
done

PARTS=/opt/scripts/"${script_type}-${script_context}"

[ ! -d "${PARTS}" ] || exec run-parts --exit-on-error "${PARTS}" "${ARGS[@]}"
