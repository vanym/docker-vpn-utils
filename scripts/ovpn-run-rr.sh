#!/bin/bash

rr_init(){
  local RRLINK="$1"
  local RRPREFIX="$2"
  [[ "$(readlink $RRLINK)" =~ $RRPREFIX([0-9]{2,}) ]] || \
    ln -sfT "$RRPREFIX"00 "$RRLINK"
}

rr_rotate(){
  local RRLINK="$1"
  local RRPREFIX="$2"
  if [[ "$(readlink "$RRLINK")" =~ $RRPREFIX([0-9]+) ]] &&
    {
      RR=$(printf '%02d\n' $((${BASH_REMATCH[1]#0}+1))) ;
      RRPATH="$RRPREFIX""$RR" ;
      [ -e "$RRPATH" ] ;
    }
  then
    ln -sfT "$RRPATH" "$RRLINK"
  else
    ln -sfT "$RRPREFIX"00 "$RRLINK"
  fi
}
