==============================
ALR Research and configuration
==============================
Introduction
============
Reasoning
=========
|This document serves as a structured record of the research, design decisions, and configuration 
behind my SALR(Secondary Arch Linux Router) project. It documents not only what was configured, 
but why each choice was made, with the goal of building a router platform that is fully understood 
rather than merely functional.

|Arch Linux was chosen deliberately. While familiarity and personal affinity played a role, 
the primary motivation was intentional difficulty. Instead, I wanted full control over the operating 
system and network stack so I could understand the systemd as deeply as possible, down to the level 
where behavior is explained by configuration and design rather than assumption. Reviewing kernel 
or daemon source code is not the immediate goal, but this project is designed to build a foundation 
where doing so later would be meaningful rather overwhelming.

|This approach forces learning to stick for me. By assembling the system piece by piece, I gain a 
concrete understanding of how Linux-based routers actually work. Routing, firewalls, DNS, DHCP, VPNs, 
and service isolation as they exist in real infrastructure. This reflects how much of modern IT and 
networking is built today, Linux servers acting as the backbone of enterprise and service-provider 
environments.

|Linux's flexibility and transparency are central to this project. The freedom to design the system 
explicitly, rather than adapt to a predefined architecture, is both more educational and more engaging. 
This work also aligns with my near-term professional goals of pursuing the CCNA and LPIC-1 certifications, 
grounding theoretical knowledge in a practical, production like system.

|For the reasons, purpose built router operating systems such as VyOS, OpenWRT, OPNsense, and Mikrotik 
were intentionally avoided. While they are excellent platforms, they abstract away too many implementation 
details for the learning objectives of this project. The goal of SALR is not convenience or speed of 
deployment it is full ownership of the system, from boot to packets flowing.
|

Documentation Structure and Organization
========================================
|This document is not ordered as a strict step-by-step build guide. The work on SALR was not linear, 
and presenting it that way would misrepresent how the system was actually built and deployed. 
Configuration and research moved back and forth between components as problems surfaced and design 
decisions changed. Changes in one area often required revisiting others. Progress happened through 
iteration rather than sequence.

|For that reason, the document is organized by the system components and services, not by time. 
Each major area has its own section. These sections may reference commands, notes or troubleshooting 
steps that were used outside the narrow scope of that component, but were relevant at the time. 
So some material appears in sections where it may not traditionally belong. This is intentional. 
For example, BTRFS commands appear under the containerization section because BTRFS subvolumes are 
used to store containers, and those commands were primarily used to inspect container disk usage. 
Each section is meant to function as a focused reference for understanding, modifying or rebuilding 
that part of the system.
|

BTRFS
=====
Links:
------
[https://archive.kernel.org/oldwiki/btrfs.wiki.kernel.org/index.php/SysadminGuide.html#Copy_on_Write_.28CoW.29]
[https://wiki.archlinux.org/title/Btrfs#btrfs_check]
[https://man.archlinux.org/man/btrfs.5]
[https://man.archlinux.org/listing/core/btrfs-progs/]
[https://man.archlinux.org/man/core/btrfs-progs/btrfs-subvolume.8.en]
[https://www.youtube.com/watch?v=RPO-fS6HQbY]

#: the process for changing all files in a dir to the parent directories attribute::
$ mv /path/to/dir /path/to/dir_old
$ mkdir /path/to/dir
$ chattr +C /path/to/dir
$ cp -a --reflink=never /path/to/dir_old/. /path/to/dir
$ rm -rf /path/to/dir_old

#: running the cp command for files on btrfs partition, the files/dir copied over will inherit the
#: subvolumes [if the subvolume is mounted with nodatacow] and dirs with nocow attr 

#: Mounting and creating btrfs subvolumes::
$ mount device /mnt/ -o subvolid=5
$ btrfs subvolume create /mnt/subvol_root/
$ btrfs subvolume create /mnt/sub
$ umount /mnt/
$ mount -o subvol=/subvol_root device /mnt/
$ mount -o subvol=/subvol_home --mkdir device /mnt/home/

KERNEL {LINUX-HARDENED}
=======================
#: Using the linux-hardened kernel I seem to have run in the problem of the sd-vconsole hook and other 
#: hooks related to the vconsole because I dont ever configure the vconsole config file on any of my 
#: systems so i had to learn more about mkinitcpio command and configs.

Links:
------
[https://wiki.archlinux.org/title/Mkinitcpio#Using_net]

CONTAINERIZATION {SYSTEMD-NSPAWN}
=================================
#: using btrfs subvolume as a container root::
$ btrfs subvolume create ~/MyContainer
$ pacstrap -K -c ~/MyContainer base [[additional packages/groups]]
$ systemd-nspawn -D ~/MyContainer #this drops you into container.
$ systemd-nspawn -b -D ~/MyContainer #this boots and drops you in.
$ machinectl enable/start MyContainer


#: showing specific disk usage of btrfs subvolumes/nspawn containers::
$ sudo btrfs fi du -s /var/lib/machines/MyContainer

#: this is the output from my containers pre-configuration but fully installed::
$ sudo btrfs fi du -s /var/lib/machines/rdns-container
     Total   Exclusive  Set shared  Filename
 722.82MiB   722.82MiB       0.00B  /var/lib/machines/rdns-container::
$ sudo btrfs fi du -s /var/lib/machines/kea-container
     Total   Exclusive  Set shared  Filename
 747.68MiB   747.68MiB       0.00B  /var/lib/machines/kea-container::
$ sudo btrfs fi du -s /var/lib/machines/wg-container
     Total   Exclusive  Set shared  Filename
 683.22MiB   683.22MiB       0.00B  /var/lib/machines/wg-container

#: the command for spinning containers with a base snapshot system::
$ systemd-nspawn --template=/.snapshots/403/snapshot -b -D my-container

#: machinectl commands::
$ machinectl shell root@container


Links:
------
|https://wiki.archlinux.org/title/Systemd-nspawn
https://man.archlinux.org/man/systemd-nspawn.1
https://man.archlinux.org/man/machinectl.1
https://man.archlinux.org/man/systemd.nspawn.5.en
|
BIRD2 {ROUTING PROTOCOL DAEMON}
===============================
#: this along with nftables will remain on main system and not be containerized because i want my 
#: routing protocols to live closer to the kernel and interact well with firewall and kernel parameters 
#: I will be setting. 



NFTABLES
========

#: these commands just load and list ruleset you've made::
$ nft -f /etc/*.nft or /etc/*.conf
$ nft list ruleset


Links:
------
[https://www.youtube.com/watch?v=K8JPwbcNy_0&list=PLUF494I4KUvqwDjhOoP3IFUpgEhE1OVDO]
[https://www.youtube.com/watch?v=YLVKuA4kiMA&list=PLUF494I4KUvqwDjhOoP3IFUpgEhE1OVDO&index=2]
[https://man.archlinux.org/man/nft.8]
[https://wiki.archlinux.org/title/Nftables]

NETWORKD
========
|Made an IPVLAN along with 3 VLAN interfaces ontop of the existing "eno1" interface.
IPVLAN is in bridge and L3 mode. Made .nspawn file for containers attaching eno1 as the IPVLAN bridge.
|

Links:
------
#: since systemd is so monolithic these are all networkd and related man pages:
https://man.archlinux.org/search?q=networkd&go=Go
#: .netdev files and their config parameters:
https://man.archlinux.org/man/systemd.netdev.5.en
#: this is the man page for setting .network files:
https://man.archlinux.org/man/systemd.network.5.en
#: networkctl commands and more config options:
https://man.archlinux.org/man/networkctl.1.en

KEA + MariaDB {DHCP}
====================

|Kea will be configured with the MariaDB backend mostly so I have stored leasefiles but this will be my 
first step into a backend database for a DHCP server. The kea-dhcp4 server was first JSON file to be 
made. Getting ready to configure MariaDB, obviously a lot of the config is not needed but none the less
I will be configuring the database first before starting up kea service. Using the InnoDB engine for MariaDB.
Configured MariaDB Server and create a user 
|

#: MariaDB SQL commands for setting up MariaDB server::
@ MariaDB> SELECT @@system_time_zone;
@ MariaDB> SELECT @@global.time_zone;
@ MariaDB> SELECT @@session.time_zone;
@ MariaDB> CREATE USER 'kea'@'localhost' IDENTIFIED BY '**********'
@ MariaDB> CREATE DATABASE kea_db;
@ MariaDB> GRANT ALL ON kea_db.* TO 'kea'@'localhost';
#: keactrl command; shell script controls the start, shutdown, and reconfig of kea servers::
$ keactrl <command> [-c keactrl-config-file] [-s server[,server,...]]

Links:
------
[https://kea.readthedocs.io/en/stable/arm/admin.html]
[https://wiki.archlinux.org/title/Kea]
[https://wiki.archlinux.org/title/MariaDB]
[https://mariadb.com/docs/server]
[https://kea.readthedocs.io/en/stable/arm/dhcp4-srv.html#dhcpv4-server-configuration]
[https://datatracker.ietf.org/doc/html/rfc2131#appendix-A]
#: This is a detailed report from ISC detailing the perfomance differences between different leasing types
[https://reports.kea.isc.org/performance/stable/2.6.4/report.html]
USER AND GROUPS {DAC}
=====================
UNBOUND {rDNS}
==============

