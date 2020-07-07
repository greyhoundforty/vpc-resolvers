#!/usr/bin/env bash

## Update machine
DEBIAN_FRONTEND=noninteractive apt -qqy update
DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade
DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install unzip curl git jq 

cat >/etc/netplan/99-custom-dns.yaml <<EOL
network:
    version: 2
    ethernets:
        ens3:
            nameservers:
                addresses: [ "161.26.0.7", "161.26.0.8" ]
            dhcp4-overrides:
                use-dns: false
EOL

netplan apply
echo "supersede domain-name-servers 161.26.0.7, 161.26.0.8;" | tee -a /etc/dhcp/dhclient.conf
dhclient -v -r; dhclient -v
systemd-resolve --flush-caches