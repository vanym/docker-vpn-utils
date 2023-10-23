# Docker VPN Utils

This repository contains a docker compose template and utils scripts to run a VPN in docker containers.
The VPN connection happens in *VPN* container, but network interface attaches to another individual *route* container.
**Check other branches for more features!**

## WireguardServer

This branch has *wireguardserver* container that adds a wireguard interface to *route* configured to forward packets from the wireguard network to the route network.
Peers of the wireguard network are isolated from each other.

Use `wireguardserver/makekeys.sh`, `wireguardserver/addpeer.sh` scripts to initial configure of the wireguard network.

## DNS

This branch has *dnsmasq* container that runs DNS relay in *route* network.

## Scripts

There is some scripts:

 - `wireguardserver/makekeys.sh` — generate initial keys of the wireguard network
 - `wireguardserver/addpeer.sh` — adds peer to the wireguard config and outputs config for that peer

Scripts from `wireguardserver/scripts` directory used inside container
