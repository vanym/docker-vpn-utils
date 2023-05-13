#!/bin/bash
# based on https://github.com/pekman/openvpn-netns/blob/master/openvpn-scripts/netns

set -e

case $script_type in
  up)
    ip link set dev "$dev" up netns "$NETNS" mtu "$tun_mtu"
    netmask4="${ifconfig_netmask:-30}"
    netbits6="${ifconfig_ipv6_netbits:-112}"
    if [ -n "$ifconfig_local" ]; then
      ip netns exec "$NETNS" \
        ip -4 addr add \
          local "$ifconfig_local"${ifconfig_remote:+ peer "$ifconfig_remote"}/"$netmask4" \
          ${ifconfig_broadcast:+broadcast "$ifconfig_broadcast"} \
          dev "$dev"
    fi
    if [ -n "$IPV6" -a -n "$ifconfig_ipv6_local" ]; then
      ip netns exec "$NETNS" \
        ip -6 addr add \
          local "$ifconfig_ipv6_local"${ifconfig_ipv6_remote:+ peer "$ifconfig_ipv6_remote"}/"$netbits6" \
          dev "$dev"
    fi
    if [ -n "$DNS" ]; then
      RESOLVCONF_PATH=/etc/netns/"$NETNS"/resolv.conf
      echo "# Generated by $(basename ${BASH_SOURCE[0]})" > "$RESOLVCONF_PATH"
      RESOLVCONF_DOMAINS=()
      RESOLVCONF_SEARCHS=()
      process_foreign_option(){
        case "$1:$2" in
          dhcp-option:DNS)
            echo "nameserver $3" >> "$RESOLVCONF_PATH"
          ;;
          dhcp-option:DNS6)
            echo "nameserver $3" >> "$RESOLVCONF_PATH"
          ;;
          dhcp-option:DOMAIN)
            RESOLVCONF_DOMAINS+=("$3")
          ;;
          dhcp-option:DOMAIN-SEARCH)
            RESOLVCONF_SEARCHS+=("$3")
          ;;
        esac
      }
      while eval 'OPT="$foreign_option_'$((++i))\"; [ -n "$OPT" ]; do
        process_foreign_option $OPT
      done
      unset i
      if [ "${#RESOLVCONF_DOMAINS[@]}" -eq 1 ]; then
        echo "domain ${RESOLVCONF_DOMAINS}" >> "$RESOLVCONF_PATH"
      else
        RESOLVCONF_SEARCHS+=(${RESOLVCONF_DOMAINS[@]})
      fi
      if [ "${#RESOLVCONF_SEARCHS[@]}" -gt 0 ]; then
        echo "search ${RESOLVCONF_SEARCHS[@]}" >> "$RESOLVCONF_PATH"
      fi
    fi
  ;;
  route-up)
    while
      eval 'network="$route_network_'$((++i))\"
      eval 'netmask="$route_netmask_'$i\"
      eval 'gateway="$route_gateway_'$i\"
      eval 'metric="$route_metric_'$i\"
      [ -n "$network" ]
    do
      ip netns exec "$NETNS" \
        ip -4 route add "$network/$netmask" via "$gateway" ${metric:+metric "$metric"}
    done
    unset i
    if [ -n "$route_vpn_gateway" ]; then
      ip netns exec "$NETNS" \
        ip -4 route add default via "$route_vpn_gateway"
    fi
    if [ -n "$IPV6" ]; then
      while
        eval 'network="$route_ipv6_network_'$((++i))\"
        eval 'gateway="$route_ipv6_gateway_'$i\"
        [ -n "$network" ]
      do
        ip netns exec "$NETNS" \
          ip -6 route add "$network" via "$gateway" metric 100
      done
      unset i
      if [ -n "$ifconfig_ipv6_remote" ]; then
        ip netns exec "$NETNS" \
          ip -6 route add default via "$ifconfig_ipv6_remote" metric 200
      fi
    fi
  ;;
  down) ;;
esac
