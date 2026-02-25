==============================
ALR Research and Configuration
==============================
-----------------
Arch Linux Router
-----------------

Introduction
============
Hello everyone reading this paper, my name is Tre Porter or Atkzero on social platforms. This project 
is a passion project mixed with a insatiable urge to learn. I intend for this project to allow me to explore 
technologies in a not so convential way, so after stumbling on to a router section on arch linux wiki I 
found another oppurtunity I didnt even think possible till I built my first router and it came out perfect or 
atleast perfect in my eyes for what I would need a home router. Then I realized it was nice and cool but I wanted 
to keep going and configure another and this time allow myself to step deeper and not be afraid of expanding the scope 
of the project to do something that I would say takes a little more skill and nuance.

This is not a how to 

Reasoning
---------
This document serves as a structured record of the research, design decisions, and configuration 
behind my SALR(Secondary Arch Linux Router) project. It documents not only what was configured, 
but why each choice was made, with the goal of building a router platform that is fully understood 
rather than merely functional.

Arch Linux was chosen deliberately. While familiarity and personal affinity played a role, 
the primary motivation was intentional difficulty. Instead, I wanted full control over the operating 
system and network stack so I could understand the systemd as deeply as possible, down to the level 
where behavior is explained by configuration and design rather than assumption. Reviewing kernel 
or daemon source code is not the immediate goal, but this project is designed to build a foundation 
where doing so later would be meaningful rather overwhelming.

This approach forces learning to stick for me. By assembling the system piece by piece, I gain a 
concrete understanding of how Linux-based routers actually work. Routing, firewalls, DNS, DHCP, VPNs, 
and service isolation as they exist in real infrastructure. This reflects how much of modern IT and 
networking is built today, Linux servers acting as the backbone of enterprise and service-provider 
environments.

Linux's flexibility and transparency are central to this project. The freedom to design the system 
explicitly, rather than adapt to a predefined architecture, is both more educational and more engaging. 
This work also aligns with my near-term professional goals of pursuing the CCNA and LPIC-1 certifications, 
grounding theoretical knowledge in a practical, production like system.

For the reasons, purpose built router operating systems such as VyOS, OpenWRT, OPNsense, and Mikrotik 
were intentionally avoided. While they are excellent platforms, they abstract away too many implementation 
details for the learning objectives of this project. The goal of SALR is not convenience or speed of 
deployment it is full ownership of the system, from boot to packets flowing.


Documentation Structure and Organization
----------------------------------------
This document is not ordered as a strict step-by-step build guide. The work on SALR was not linear, 
and presenting it that way would misrepresent how the system was actually built and deployed. 
Configuration and research moved back and forth between components as problems surfaced and design 
decisions changed. Changes in one area often required revisiting others. Progress happened through 
iteration rather than sequence.

For that reason, the document is organized by the system components and services, not by time. 
Each major area has its own section. These sections may reference commands, notes or troubleshooting 
steps that were used outside the narrow scope of that component, but were relevant at the time. 
So some material appears in sections where it may not traditionally belong. This is intentional. 
For example, BTRFS commands appear under the containerization section because BTRFS subvolumes are 
used to store containers, and those commands were primarily used to inspect container disk usage. 
Each section is meant to function as a focused reference for understanding, modifying or rebuilding 
that part of the system.


BTRFS
=====
btrfs is the filesystem I decided to use for restoring backups easier and for the purpose of learning other filesystems. 
btrfs is pretty extensive and took me a while to gather a general understanding of how it works, it also is worth digging 
further into. I decided to create 3 child subvolumes of the subvolume with id 5, I made one for /home, /, and a /@backups 
so these subvolumes are not copied when making a snapshot of / directory and same goes for /home. /@backups will not be snapshotted, 
it will only host the incremental backups of containers, / and /home. I created subvolumes for my containers, I will eventually
take those and create quotas and such just to play around more with them.

#: the process for changing all files in a dir to the parent directories attribute
.. code-block:: bash
   mv /path/to/dir /path/to/dir_old
   mkdir /path/to/dir
   chattr +C /path/to/dir
   cp -a --reflink=never /path/to/dir_old/. /path/to/dir
   rm -rf /path/to/dir_old

#: running the cp command for files on btrfs partition, the files/dir copied over will inherit the
#: subvolumes [if the subvolume is mounted with nodatacow] and dirs with nocow attr 

#: Mounting and creating btrfs subvolumes underneath the btrfs top level dir
.. code-block:: bash
   mount device /mnt/ -o subvolid=5
   btrfs subvolume create /mnt/subvol_root/
   btrfs subvolume create /mnt/sub
   umount /mnt/
   mount -o subvol=/subvol_root device /mnt/
   mount -o subvol=/subvol_home --mkdir device /mnt/home/

#: Snapshots and backing-up
.. code-block:: bash
  $ btrfs subv snapshot -r /var/lib/machines/kea-container /@backups/ro-keabackup20260216
  $ btrfs subv snapshot -r /var/lib/machines/rdns-container /@backups/ro-rdnsbackup20260216
  $ btrfs subv snapshot -r / /@backups/ro-rootbackup20260216
#: commands to populate snapshots on grub [please read docs because if you have backups of nested subvolumes then you'll 
have to get those by mounting, deleting and moving]
.. code-block:: bash
  $ pacman -S grub-btrfs
  $ vim /etc/mkinitcpio.conf
  # added the grub-btrfs-overlayfs hook and procceeded
  $ mkinitcpio -P
  $ grub-mkconfig -o /boot/grub/grub.cfg

#: installing and configuring grub-btrfs, had to apply the mkinitcpio hook for grub-btrfs then run the mkinitpcio command to 
include that hook. Then ran the grub mkconfig command to reproduce the grub.cfg to host my snapshots and such. I had to change 
my fstab file to allow grub to pass the subvolume that will be booted as root to the kernel instead of allow fstab to do so. I chose
to do it this way so I could one better understand how all of btrfs works and essentially how to rollback my subvolumes or containers.
I am going to use snapper or timeshift in the near future to automate alot of this only once I've fully grasped rolling back manually.
for now I have a basic understanding on how to rollback effectively without losing data if need be but I still want a deeper understanding, 
so for now every rollback if one is needed will be manual and I'll make sure to keep backups before updates using pacman -Syu. This 
file system has made me want to use on my main Arch system since rollbacks would be crucial for rolling releases.

#: commands used for getting btrfs setup for proper use and rollback if need be.
.. code-block:: bash
  $ pacman -S grub-btrfs
  $ vim /etc/mkinitcpio.conf # here I made the neccessary changes to build with proper hooks and was changed previosly to accomadate for linux-hardened
  $ mkinitpcio -L # list the available hooks
  $ mkinitpcio -P # rebuild the hooks that were added above
  $ grub-mkconfig -o /boot/grub/grub.cfg
  # This command below was used to verify I was inside of a actual snapshot 
  $ findmnt -no source /
  /dev/sda2[/@backups/root_backuptest] # this is the output shown when booted into the right snapshot

#: Other useful btrfs commands:
.. code-block:: bash
  $ btrfs subv show / #used for any subvolume, 
  $

Links:
------
[https://archive.kernel.org/oldwiki/btrfs.wiki.kernel.org/index.php/SysadminGuide.html#Copy_on_Write_.28CoW.29]
[https://wiki.archlinux.org/title/Btrfs#btrfs_check]
[https://man.archlinux.org/man/btrfs.5]
[https://man.archlinux.org/listing/core/btrfs-progs/]
[https://man.archlinux.org/man/core/btrfs-progs/btrfs-subvolume.8.en]
[https://www.youtube.com/watch?v=RPO-fS6HQbY]
[https://www.youtube.com/watch?v=71AnM15TDYw]
[https://wiki.archlinux.org/title/System_backup]
[https://btrfs.readthedocs.io/en/latest/btrfs-subvolume.html#subvolume-and-snapshot]

KERNEL {LINUX-HARDENED}
=======================
Using the linux-hardened kernel I seem to have run in the problem of the sd-vconsole hook and other 
hooks related to the vconsole because I dont ever configure the vconsole config file on any of my 
systems so i had to learn more about mkinitcpio command and configs.

Decided to change some kernel parameters mostly pertaining to network parameters. Realized most security 
related parameters were already set by linux-hardened, I will eventually take a deeper dive into kernel parameters
for security purposes mostly. I put only a few changes into a networking.conf inside /etc/sysctl.d/ directory. 

Getting into the ethtool command line to check packet drops and changing networking parameters for better through put and latency.
.. code-block:: bash
   $ ethtool -S eno1
   $ sysctl -a
   $ sysctl -w /etc/sysctl.d/networking.conf

   # These commands below are esentially what I ran to update the 
   # appropriate kernel parameters for maximize networking features
   
   $ sysctl -w net.core.netdev_max_backlog=16384
   $ sysctl -w net.core.somaxconn=8192
   $ sysctl -w net.ipv4.tcp_max_syn_backlog=8192
   $ sysctl -w net.ipv4.tcp_max_tw_buckets=2000000
   $ sysctl -w net.ipv4.tcp_tw_reuse=1
   $ sysctl -w net.ipv4.tcp_syncookies=1
   $ sysctl -w net.core.default_qdisc=fq
   $ sysctl -w net.ipv4.tcp_congestion_control=bbr
   $ sysctl -w net.ipv4.conf.all.rp_filter=1

Links:
------
[https://wiki.archlinux.org/title/Mkinitcpio#Using_net]
[https://wiki.archlinux.org/title/Sysctl#Networking]
[https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf]
CONTAINERIZATION {SYSTEMD-NSPAWN}
=================================
Had to run cli commands for btrfs to create a subvolume for the container inside "/var/lib/machines/", this then 
had to be followed by a pacstrap command to create a archlinux container housing my respective services (kea and bind).
I decided to use host networking instead of seperating the containers per ip since I have multiple VLANs, I may do it 
in the future but for now it will remain as host networking. There was no need to seperate it in such a way anyways.

Had to bind some files for zsh configs to take place across both containers and networking settings for host-networking. 
the containers 
#: using btrfs subvolume as a container root
.. code-block:: bash
   btrfs subvolume create ~/MyContainer
   pacstrap -K -c ~/MyContainer base [[additional packages/groups]]
   systemd-nspawn -D ~/MyContainer #this drops you into container.
   systemd-nspawn -b -D ~/MyContainer #this boots and drops you in.
   machinectl enable/start MyContainer

# Containers base install:
.. code-block:: bash 
  sudo btrfs fi du -s /var/lib/machines/MyContainer //showing specific disk usage of btrfs subvolumes/nspawn containers
  sudo btrfs fi du -s /var/lib/machines/rdns-container
     Total   Exclusive  Set shared  Filename
 722.82MiB   722.82MiB       0.00B  /var/lib/machines/rdns-container
  sudo btrfs fi du -s /var/lib/machines/kea-container
     Total   Exclusive  Set shared  Filename
 747.68MiB   747.68MiB       0.00B  /var/lib/machines/kea-container
  
# Containers after completion:
.. code-block:: bash
  ❯ btrfs fi du -s /var/lib/machines/kea-container
     Total   Exclusive  Set shared  Filename
   2.24GiB    18.46MiB     2.22GiB  /var/lib/machines/kea-container
  ❯ btrfs fi du -s /var/lib/machines/rdns-container
     Total   Exclusive  Set shared  Filename
   1.30GiB     9.86MiB     1.29GiB  /var/lib/machines/rdns-container
#: the command for spinning containers with a base snapshot system
.. code-block:: bash
  $ systemd-nspawn --template=/@backups/snapshot -b -D /var/lib/machines/my-container

#: machinectl commands
.. code-block:: bash
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
this along with nftables will remain on main system and not be containerized because i want my 
routing protocols to live closer to the kernel and interact well with firewall and kernel parameters 
I will be setting. This part of the router will be implementented right away after configuring another router
most likely through proxmox even though I think this will be much for such short connections and not a very small 
network I will use it and play around with it until I get to bring these ideas and assumptions into a gns3 lab that 
my homelab will be setup for. so this router will be subject to a "downgrade" of some of these softwares and services.




NFTABLES
========
NFTables was simply setup in a stateful auto deny on input and foward chains. I obviously put in a srcnat to
to masquerade on outgoing interface. Nftables was relatively simple since only mimicing regular router functionality.
This firewall will however serve as a great asset when growing my lab out to do different things and get into 
other projects like VPNs and such. 

#: these commands just load and list ruleset you've made
.. code-block:: bash
  $ nft -f /etc/lamb.nft
  $ nft list ruleset
..

Links:
------
[https://www.youtube.com/watch?v=K8JPwbcNy_0&list=PLUF494I4KUvqwDjhOoP3IFUpgEhE1OVDO]
[https://www.youtube.com/watch?v=YLVKuA4kiMA&list=PLUF494I4KUvqwDjhOoP3IFUpgEhE1OVDO&index=2]
[https://man.archlinux.org/man/nft.8]
[https://wiki.archlinux.org/title/Nftables]
[https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_home_router]
[https://www.youtube.com/watch?v=dnkuDjblI-k&list=PLsYMit2eI6VWcwaOCuNI3mPZ8t6palQx5&index=1]

NETWORKD
========
Made a bridge [br25] on top of cntrl VLAN interface on the router since bridge made the most sense 
for my use case. Had to change the systemd-nspawn@service to stop using the --network-veth option and 
change to --network-bridge=br25. This was needed because I was having problems with a ve* container interface 
being made and not attatching to the right interfaces.

#: These commands help hunt down the culprit of my problem::
$ networkctl edit [DEVICE NAME]
$ networkctl reload
$ systemctl status systemd-nspawn@container-name
$ bridge link

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

Kea will be configured with the MariaDB backend mostly so I have stored hosts files, and memfiles will 
used to handle lease files. The performance boost for this specific setup is detailed in [Link 9] below. 
This will be my first step into a backend database for a DHCP server. The kea-dhcp4 server was first JSON file 
to be made. Getting ready to configure MariaDB, obviously a lot of the config is not needed but none the less
I will be configuring the database first before starting up kea service. Using the InnoDB engine for MariaDB.
Configured MariaDB Server and create a user. Kea crossreferences alot of dns topics due to the DDNS options and 
the nature of DHCP and their options. For example setting up a DNR option for dhcpv4 server:

Kea had to be troubleshot quite a bit and configurations changed to allow for seemless updating and dhcp6 was new, 
had to think about how ipv6 addresses would be allocated to end devices, since I want to play a bit with ipv6 addresses, 
and AAAA records I would like to have them auto update together, as of now only the A records are being updated even though 
end devices are recieving ipv6 addresses.

"data": "2, rdns-container.cntrl., 172.25.44.12, alpn=dot\\,doq port=8530"
json file config for v4-dnr options above ^. Configuring the JSON v4 took 2 days to finish up. 
The dhcpv6 is the next one to configure.



#: MariaDB SQL commands for setting up MariaDB server
.. code-block:: mysql
  MariaDB> SELECT @@system_time_zone;
  MariaDB> SELECT @@global.time_zone;
  MariaDB> SELECT @@session.time_zone;
  MariaDB> CREATE USER 'kea'@'localhost' IDENTIFIED BY '**********'
  MariaDB> CREATE DATABASE kea_db;
  MariaDB> GRANT ALL ON kea_db.* TO 'kea'@'localhost';
# keactrl command; shell script controls the start, shutdown, and reconfig of kea servers
.. code-block:: bash
  $ keactrl <command> [-c keactrl-config-file] [-s server[,server,...]]

Links:
------
[1.] [https://kea.readthedocs.io/en/stable/arm/admin.html]
[2.] [https://wiki.archlinux.org/title/Kea]
[3.] [https://wiki.archlinux.org/title/MariaDB]
[4.] [https://mariadb.com/docs/server]
[5.] [https://kea.readthedocs.io/en/stable/arm/dhcp4-srv.html#dhcpv4-server-configuration]
[6.] [https://datatracker.ietf.org/doc/html/rfc2131#appendix-A]
#: This is a detailed report from ISC detailing the perfomance differences between different leasing types
[7.] [https://reports.kea.isc.org/performance/stable/2.6.4/report.html]
#: RFC 9463
[8.] [https://datatracker.ietf.org/doc/html/rfc9463]
#: RFC 8499 {referenced in RFC 9463 just holds terminology for DNS}
[9.] [https://datatracker.ietf.org/doc/html/rfc8499]
#: Kea Example docs
[10.] [https://gitlab.isc.org/isc-projects/kea/-/blob/master/doc/examples/kea4/all-options.json]
[11.] [https://github.com/isc-projects/kea/blob/master/doc/examples/kea6/all-options.json]
USER AND GROUPS {DAC}
=====================
BIND {rDNS}
==============
So for Unbound I set it up for local authority and recursion. I made zone files for each of my "TLD"[Local Only]
and the respective PTR zone files. I had the option of using local-zone or RPZ (Response Policy Zone) option as well
as setting auth-zone option and I chose to use auth-zone so I could construct my own zone-file and learn more.
Made a dnskey from the command below. In order to allow kea-dhcp-ddns service to update new zone files, I had to
generate a key with tsig-key from the bind package, but I should have used ldns-keygen instead since it can do the same.
I did basic configs for allowing my unbound config file to act as a recursive and validating resolver. Had to download
root.hints file from [Link 1]. This was based on the previous assumption that unbound would be able to handle ddns updates,
and was sorely mistaken. So I decided to go through with using bind as my recursive and authoritative resolver. I used the 
same zone files I made for unbound and placed them inside "/var/named/zonefiles.lamb.d/". I had to make sure to make an ACL 
that explicity stated my vlan interfaces ipv4 and ipv6 and point recursion and queries coming from those networks and allow the
loopback interfaces for ddns updates from kea-dhcp-ddns. A lot of troubleshooting was involved in the process of getting my zonefiles to update 
properly and signed correctly. *EXPAND THIS SECTION*

Bind was pretty straightforward as far as setup goes more will be added to this and not many commands were needed, mostly 
configuration differences. 

.. code-block:: bash
   unbound-anchor -a /path/to/key/name-of-key
   wget -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache
   chown -R named:named /etc/named.conf
   chown -R named:named /var/named/

Links:
------
[1.] [https://www.internic.net/domain/named.cache]
[2.] [https://www.youtube.com/watch?v=HJHOkZb1bQQ]
[3.] [https://man.archlinux.org/man/named.conf.5]
[4.] [https://datatracker.ietf.org/doc/html/rfc4703#section-5.2]
[5.] []
[6.] []
