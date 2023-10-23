# Docker VPN Utils

This repository contains a docker compose template and utils scripts to run a VPN in docker containers.
The VPN connection happens in *VPN* container, but network interface attaches to another individual *route* container.
**Check other branches for more features!**

## OpenVPN

To configure OpenVPN place the ovpn.conf file in the `./vpn` directory, you can also specify additional command line arguments in the `docker-compose.yml` file. Your [scripting integrations](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-5/#scripting-integration) can be placed in `./scripts/up-init`, `./scripts/down-init`, etcetera.

### Round robin

Directory `./vpn/rr` contains `always`, `auth-failure`, `connection-failure` symlinks that points to `always.d/00`, `auth-failure.d/00`, `connection-failure.d/00` respectively and change to next number named directory, after the event corresponding link name hapends.

 - `always` — every container restart
 - `auth-failure` — every auth failure
 - `connection-failure` — after exceed `connect-retry-max`

## WireguardServer

This branch has *wireguardserver* container that adds a wireguard interface to *route* configured to forward packets from the wireguard network to the route network.
Peers of the wireguard network are isolated from each other.

Use `wireguardserver/makekeys.sh`, `wireguardserver/addpeer.sh` scripts to initial configure of the wireguard network.

## DNS

This branch has *dnsmasq* container that runs DNS relay in *route* network.

## Scripts

There is some scripts:

 - `addnetns.sh` — adds symlinks to `/etc/netns` and `/var/run/netns` directories to give ability to enter *route* network namespace using `ip netns exec` command
 - `delnetns.sh` — removes symlinks added by `addnetns.sh` from `/etc/netns`, `/var/run/netns` directories
 - `enterns.sh` — enters *route* network namespace using `addnetns.sh` and `ip netns exec`
 - `userns.sh` — same as `enterns.sh` but with sudo wrapper
 - `addbypass.sh` — adds ip rule with 30000 priority to use main routing table for packets from *VPN* container
 - `delbypass.sh` — removes ip rule added by `addbypass.sh`
 - `wireguardserver/makekeys.sh` — generate initial keys of the wireguard network
 - `wireguardserver/addpeer.sh` — adds peer to the wireguard config and outputs config for that peer

Scripts from `./scripts`, `wireguardserver/scripts` directories used inside containers

## VPN Chain

To build a VPN chain you need to setup two (or more) instances of containerized VPN and use *route* container from fisrt as [network](https://docs.docker.com/compose/compose-file/compose-file-v3/#network_mode) for *VPN* container from second one.
You should limit packets size from second instance to pass size limit of first one (`--mssfix 1400` [in OpenVPN](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-5/#network-configuration)).
Also it would be good to set different network interface names (`--dev` in OpenVPN).
