==============================
ALR Research and Configuration
==============================
-----------------
Arch Linux Router
-----------------

Introduction
============
Hello everyone reading this paper, my name is Tre or Atkzero on social platforms. This project began 
as a personal experiment driven by curiosity and an insatiable desire to learn. After discovering the 
router section of the Arch Linux Wiki, I realized it was possible to build a fully functional router 
using a general-purpose Linux distribution.

My first attempt worked surprisingly well for a home environment, which led me to push further. Rather 
than stopping at a basic configuration, I decided to build another router while deliberately expanding 
the scope of the project to explore more complex networking concepts and system design decisions.

Reasoning
---------
This document serves as a structured record of the research, design decisions, and configuration 
behind my ALR(Arch Linux Router) project. It documents not only what was configured, but why each choice 
was made, with the goal of building a router platform that is fully understood rather than merely functional.

Arch Linux was chosen deliberately. While familiarity and personal affinity played a role, 
the primary motivation was intentional difficulty. Instead, I wanted full control over the operating 
system and network stack so I could understand the system as deeply as possible, down to the level 
where behavior is explained by configuration and design rather than assumption. Reviewing kernel 
or daemon source code is not the immediate goal, but this project is designed to build a foundation 
where doing so later would be meaningful rather than overwhelming.

This approach forces learning to stick for me. By assembling the system piece by piece, I gain a 
concrete understanding of how Linux-based routers actually work. Routing, firewalls, DNS, DHCP, VPNs, 
and service isolation as they exist in real infrastructure. This reflects how much of modern IT and 
networking is built today, Linux servers acting as the backbone of enterprise and service-provider 
environments.

Linux's flexibility and transparency are central to this project. The freedom to design the system 
explicitly, rather than adapt to a predefined architecture, is both more educational and more engaging. 
This work also aligns with my near-term professional goals of pursuing the Network+ and LPIC-1 certifications, 
grounding theoretical knowledge in a practical, production like system.

For these reasons, a purpose built router operating systems such as VyOS, OpenWRT, OPNsense, and Mikrotik 
were intentionally avoided. While they are excellent platforms, they abstract too many implementation 
details for the learning objectives of this project. The goal of ALR is not convenience or speed of 
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
BTRFS was selected for system resilience and fast recovery rather than long-term data preservation. 
The primary goal for this router is uptime and reproducibility. In the event of failure or temporary 
dysfunction, I want the system to be easily restorable to a known good state with minimal downtime, 
especially using the ALPM(Arch Linux Package Management).

Between BTRFS, ZFS, LVM, Btrfs was chosen due to its snapshotting capabilities and lightweight 
integration into the Arch router. ZFS emphasizes robust software level redundancy LVM focuses on 
flexible volume management. While both are powerful, neither directly aligned with the operational 
goal of rapid roll back and simple system restoration for a router that does not require large data 
durability. 

To structure the filesystem, three child subvolumes were created from the top-level subvolume: 

- /
- /home
- /@backups

This separation ensures that snapshots of the root subvolume do not recursively capture backup data 
or unrelated subvolume contents. Likewise, /home remains independently snapshot capable. The /@backups 
subvolume is separated for backups to be stored separately and eventually be sent to the SATA SSD (128GB), 
that also will have a btrfs solely for storing backups separately. This is to ensure the longevity of SSD 
and it not being apart of the operational load of the router and the exentsive read and writes that may occur. 

Additional subvolumes were for container storage. These will later be configured else where off the router with 
Btrfs quotas to experiment with space management. Quotas are not necessary for the router's functionality, 
they provide an opportunity to explore Btrfs' more advanced capabilities. Btrfs has many different use 
cases and will be used in later projects hopefully more extensively. 


#: Running the cp command for files on btrfs partition, the files/dir copied over will inherit the
#: subvolumes [if the subvolume is mounted with nodatacow] and dirs with nocow attr 
#: Mounting and creating btrfs subvolumes underneath the btrfs top level dir

   .. code-block:: bash
  $ mount device /mnt/ -o subvolid=5
  $ btrfs subvolume create /mnt/subvol_root/
  $ btrfs subvolume create /mnt/sub
  $ umount /mnt/
  $ mount -o subvol=/subvol_root device /mnt/
  $ mount -o subvol=/subvol_home --mkdir device /mnt/home/

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
  # added the grub-btrfs-overlayfs hook and proceeded
  $ mkinitcpio -P
  $ grub-mkconfig -o /boot/grub/grub.cfg

To integrate snapshot boot support, I applied the grub-btrfs-overlayfs mkinitcpio hook and regenerated the initramfs
using mkinitcpio command. I then ran grub-mkconfig to rebuild grub.cfg, which allows GRUB to populate and boot into 
Btrfs snapshots directly. I also modified /etc/fstab to pass the target subvolume to the kernel via GRUB rather than 
letting fstab handle subvolume mounting. 

For now, rollbacks are fully manual. Before any system update, I create a snapshot as a restore point. If a rollback is 
needed, I can boot into a prior snapshot and restore from there without data loss. I have a working understanding of this 
process, but want to deepen it before introducing automation. once I have a solid grasp of the manual workflow, I plan to 
integrate either Snapper or Timeshift to automate snapshot creation and management.

Working through this on the router project has convinced me to adopt Btrfs on my main Arch system as well. On a rolling 
release like Arch, having reliable, low friction rollback capabilities is very convenient, but almost essential on a router
running a rolling release distribution.

#: Commands used for getting btrfs setup for proper use and rollback if need be.
.. code-block:: bash
  $ pacman -S grub-btrfs
  $ vim /etc/mkinitcpio.conf # here I made the necessary changes to build with proper hooks and was changed previously to accommodate for linux-hardened
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
While working with the linux-hardened kernel, I ran into an issue with the sd-vconsole hook in the mkinitcpio config 
file. The root cause was straightforward I don't configure a vconsole config file on any of my systems, which caused these 
hooks to fail. This led me to dig deeper into mkinitcpio's configuration and hook system to understand what was actually 
needed. 

After sorting out the initramfs issues, I turned my attention to kernel parameters. Most security-relevant parameters were 
already handled by linux-hardened out of the box, so I didnt need to touch those. My changes were focused on networking, which 
I placed in a dedicated file in "/etc/sysctl.d/networking.conf". Only a handful of parameters ended up there for now. I plan to 
do a more thorough review of security-related kernel parameters in the future the hardened kernel covers a lot of ground, 
but there's still value in understanding what it sets and why.

Router configuration turned out to be a good forcing function for learning. Debugging network issues pushed me towards tools like 
ethtool to inspect errors at the kernel level, and working through settings like IPv4/IPv6 forwarding alongside the sysctl networking 
parameters gave me a more concrete sense of how the kernel behaves at a low-level, no need to be a kernel developer to get value 
out of that. Nothing extreme was done here, no custom kernel compilation or anything of that scope. But enough ground was covered, 
hardened kernel behavior, mkinitcpio hooks, and network parameter tuning, that it's laid a solid foundation for going deeper into 
kernel internal in future projects.

Getting into the ethtool command line to check packet drops and changing networking parameters for better through put and latency.
.. code-block:: bash
   $ ethtool -S eno1
   $ sysctl -a
   $ sysctl -w /etc/sysctl.d/networking.conf

   # These commands below are essentially what I ran to update the 
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
Setting up the containers required a few deliberate steps. First, a Btrfs subvolume was created under /var/lib/machines/ the main 
reason being snapshotting support so containers could be rolled back and brought back up quickly. From there, pacstrap was used to bootstrap 
an Arch Linux container environment to house Kea(DHCP) and BIND(DNS). For networking, I went for host networking rather than assigning 
each container its own IP. With multiple VLANs in play, isolating them per-IP would be cleaner long-term, but host networking was the practical 
choice for now. A few bind mounts were also needed to carry over ZSH configs and apply the host networking settings across both containers. 

Both containers are being removed in favor of a more simple DNS/DHCP stack: 
- dnsmasq will take over as the authoritative DNS, stub/cache resolver, and DHCP server replacing both BIND and Kea in this environment.

- BIND will be moved to a separate Proxmox server dedicated to recursive resolution.

- Kea is being dropped entirely, since dnsmasq handles DDNS automatically alongside DHCP

The main open question is whether to migrate the existing BIND container and preserve its cached data, or simply spin up a fresh instance. 
That decision will come down to how the broader environment gets structured going forward. For small homelab setups, dnsmasq is hard to 
beat, it handles DHCP, caching, and authoritative DNS in one lightweight package. 


#: Using btrfs subvolume as a container root
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
  ❯ sudo btrfs fi du -s /var/lib/machines/kea-container
     Total   Exclusive  Set shared  Filename
   2.24GiB    18.46MiB     2.22GiB  /var/lib/machines/kea-container
  ❯ sudo btrfs fi du -s /var/lib/machines/rdns-container
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
[1.] [https://wiki.archlinux.org/title/Systemd-nspawn]
[2.] [https://man.archlinux.org/man/systemd-nspawn.1]
[3.] [https://man.archlinux.org/man/machinectl.1]
[4.] [https://man.archlinux.org/man/systemd.nspawn.5.en]

BIRD2 {ROUTING PROTOCOL DAEMON}
===============================
Routing services such as BIRD2, along with the firewall configuration handled by nftables, will remain on the host system rather than 
being containerized. The primary reason for this decision is to keep routing protocols operating as close to the Linux kernel networking 
stack as possible. Running these components directly on the host allows them to interact more naturally with kernel routing tables, 
firewall rules, and the networking parameters configured through sysctl.

The routing component of the project will be implemented after a second router is introduced into the environment, most likely as a virtual 
router hosted on a Proxmox system. While deploying a dynamic routing protocol in such a small network may be excessive from a purely practical 
standpoint, the goal here is experimentation rather than necessity. Implementing routing protocols in this environment provides an opportunity 
to explore how these systems behave and how policy decisions propagate across routers.

These early experiments will eventually be expanded into a GNS3-based lab, where larger simulated network topologies can be built and tested. 
At that stage, the ideas explored in the homelab environment can be validated under more complex routing scenarios. As the project evolves, 
the current router may be simplified and some services removed or relocated to other systems. This “downgrade” is intentional and reflects the 
experimental nature of the project, where components are added, tested, and later refactored as the overall architecture matures.


NFTABLES
========
Configuration was kept straightforward, stateful default-deny rules on the input and forwards chains, with a source NAT 
masquerade rule on the outgoing interface. This covers standard router functionality without any unnecessary complexity. 
The ruleset is minimal for now, but nftables is well-positioned to grow with the lab. As the environment expands into 
things like VPNs and more granular traffic segmentation across VLANs, having a solid, readable firewall foundation already 
in place will make that work considerably easier.

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
The network stack for the ALR project was configured using systemd-networkd. The primary motivation for this choice was simplicity, but 
also a desire to gain a deeper understanding of the systemd ecosystem, which is widely used across modern Linux server environments. Since 
the router does not require overly complex network configuration, systemd-networkd provided lightweight and direct way to manage interfaces 
without introducing unnecessary abstraction layers. An additional advantage is it's tight integration with other systemd components, like 
systemd-nspawn for containerization, journald for logs, and consistent configuration management through systemd services. 

The physical network interface eno1 acts as the parent interface for the VLAN configuration. Because the network contains three VLANs, separate 
VLAN interfaces were created using .netdev and .network files. ".netdev" files define the virtual network devices and specific parameters. ".network"
files were responsible for more granular control and able to assign ipv4 and ipv6 addresses and so much more. For example, two of the VLAN interfaces 
required additional configuration to properly support IPv6 DHCP from the Kea DHCPv6 server. these settings were to ensure link-local ipv6 addresses 
were auto assigned by the kernel and global IPv6 addresses were assigned by kea DHCPv6. 

The full network configuration files used in this project can viewed in the project's GitHub repository, which includes the exact settings required 
for VLAN creation and proper DHCPv6 integration with Kea.


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
Kea was configured with a split storage model to balance performance and persistence:

- 'Component'; 'Backend'; 'Purpose'
- Host reservations; MariaDB (InnoDB); Persistent storage for static host entries
- Lease files; Memfiles; High-performance in-memory lease tracking 

This approach uses a database only where persistence matters most, while keeping lease handling fast. This was also a 
first step into using a relational database backend for a DHCP server.

MariaDB Setup
~~~~~~~~~~~~~
MariaDB was configured before starting the Kea service. Setup steps included:

- Configuring the MariaDB server
- Creating a dedicated database user for Kea
- Using the **InnoDB** storage engine for reliability and transaction support

The `kea-dhcp4` server JSON configuration file was the first to be created, establishing the foundation before the database was brought online.

DNS Overlap in Kea Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Kea's configuration has significant overlap with DNS concepts due to its built-in DDNS options. For example, configuring 
a DNR (Discovery of Network-designated Resolvers) option for the DHCPv4 server requires understanding how DNS resolver 
discovery works at the DHCP layer. This reinforced the relationship between DHCP and DNS as closely coupled services.

IPv6 and Dual-Stack Challenges
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Configuring `kea-dhcp6` introduced new considerations around how IPv6 addresses are allocated to end devices. The goal 
was to have both A records (IPv4) and AAAA records (IPv6) auto-update in BIND when a device joined the network. In practice, 
only A records were updating despite end devices receiving IPv6 addresses.

The root cause for AAAA records to be dynamically registered alongside A records, clients must embed their IPv6 DUID within the 
IPv4 client identifier option, as specified in **RFC 4361**. This is not a default behavior and requires all clients in the 
environment to be explicitly configured to include this information in their DHCP requests. This was not pursued further, as 
fully implementing RFC 4361 across all clients was outside the intended scope of the project. However, working through the problem provided 
practical exposure to dual-stack DHCP behavior, DHCPv6 address allocation, and how DNS record updates are tied to client identity across both protocols. 
However could prove useful when presented with a new device or devices that auto configure to send that option or install script that is custom 
to your environment could help in that sense.


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
#: RFC 7341 DHCP 4o6 
[10.] [https://datatracker.ietf.org/doc/html/rfc7341]
#: RFC 4361 Node-specific client ID for DHCPv4 
[11.] [https://datatracker.ietf.org/doc/html/rfc4361]
#: Kea Example docs
[12.] [https://gitlab.isc.org/isc-projects/kea/-/blob/master/doc/examples/kea4/all-options.json]
[13.] [https://github.com/isc-projects/kea/blob/master/doc/examples/kea6/all-options.json]

BIND {DNS}
==========
DNS Setup Notes — Router Build
------------------------------
Quick Overview:
This covers the process of setting up a local DNS resolver and authoritative name server on a custom router build, 
including dynamic DNS (DDNS) integration with Kea DHCP.

Phase 1: Unbound (Initial Approach) [Later Abandoned]
-----------------------------------
Configuration Goals:
~~~~~~~~~~~~~~~~~~~~
The initial plan was to use **Unbound** as both a recursive resolver and a local authoritative server. The setup included:

- Enabling local authority and recursion
- Creating zone files for local-only pseudo-TLDs (e.g., `.lamb`, `.cntrl`)
- Creating corresponding PTR (reverse lookup) zone files

Zone files
~~~~~~~~~~
For serving local zones, Unbound offers several options:

- Option; Description
- `local-zone`; Simple inline record definitions inside `unbound.conf`
- RPZ (Response Policy Zone); Policy-based DNS manipulation
- `auth-zone`; Full zone file support — closest to standard DNS zone management

**`auth-zone` was chosen** to allow the use of standard zone file syntax and to build familiarity with 
how DNS zone files are structured.

A TSIG key was generated using tools from the BIND package. In retrospect, `ldns-keygen` would have been 
the better choice, as it produces equivalent keys and is a lighter dependency.

Basic configuration was applied to enable Unbound as a recursive and validating resolver, including:

- Downloading the `root.hints` file to bootstrap root server resolution
- Enabling DNSSEC validation

Why Unbound Was Abandoned?
~~~~~~~~~~~~~~~~~~~~~~~~~~
The core issue: **Unbound does not support dynamic DNS (DDNS) updates.** The `kea-dhcp-ddns` service 
(responsible for registering hostnames when devices join the network) requires a DNS server that can 
accept `nsupdate`-style RFC 2136 dynamic updates. Unbound cannot fulfill this role, making it unsuitable 
for this use case.



Phase 2: BIND (Final Approach)
------------------------------
The zone files created for Unbound were reused and placed into `/var/named/zonefiles.lamb.d/`. BINDs support 
for DDNS updates made it the correct tool for this setup. A named ACL was defined in `named.conf` to explicitly 
list all VLAN interface addresses (both IPv4 and IPv6). This ACL was used to:

- **Restrict recursion** to internal networks only (preventing open resolver abuse)
- **Allow queries** from those same internal networks
- **Allow DDNS updates** from the loopback interface, where `kea-dhcp-ddns` communicates

DDNS Integration with Kea
~~~~~~~~~~~~~~~~~~~~~~~~~
To allow `kea-dhcp-ddns` to update zone files automatically when new devices connect:

1. A TSIG key was generated and added to both `named.conf` and the Kea DDNS configuration file

2. An `update-policy` block was added to each zone in `named.conf`, granting update rights to 
   requests signed with that TSIG key

Getting zones to sign and update correctly required significant troubleshooting. Key issues resolved included:

- Syntax and spelling errors in `named.conf`
- Ensuring all zones were configured to be signed
- Verifying that zone files were updating correctly upon new device connections
- Confirming that signed records were being generated and served properly

Performance Tuning
~~~~~~~~~~~~~~~~~~
After noticing that initial queries were slow, this lead me to learn about cold-caches and using prefetch and increased 
cache ttl, so the following optimizations were applied:

- **Increased cache TTL** — allows records to stay cached longer, reducing repeat lookups
- **Enabled prefetching** — BIND refreshes cached records in the background before they expire, so subsequent queries 
  are served instantly rather than waiting for a fresh lookup

Key Takeaways
~~~~~~~~~~~~~
- **Unbound is a caching recursive resolver** — it is not designed to handle DDNS updates
- **BIND is the correct choice** when authoritative DNS, DDNS updates, and recursion are all required in one service
- **TSIG keys** must be identical in both `named.conf` and `kea-dhcp-ddns` config or updates will fail silently
- **ACLs are essential** — binding recursion to internal interfaces only is a security requirement, not just a best practice
- **Cache prefetching** significantly improves the perceived performance of a recursive resolver
- Working through BIND configuration builds a strong understanding of DNS concepts including: recursive vs. authoritative resolution, zone file structure, DNSSEC signing, 
  caching behavior, and dynamic update mechanisms

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
