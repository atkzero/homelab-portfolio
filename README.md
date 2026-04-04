# Homelab Documentation

## Quick Info
- **Location**: Home Office
- **Purpose**: Learning, Development, Self-hosting, Digital Freedom
- **Last Updated**: 2026-03-21 13:40

## Purpose
This repo documents all projects within my homelab environment and the reasoning behind them. It serves as both an overview of what's contained here and a running record of my experimentation.

This homelab portfolio exists primarily as a learning space. Projects documented here may succeed, fail, or evolve over time and all of that is fine with me. The goal is not to capture perfection, it is to capture the learning process itself and showcase it. Beyond showcasing projects, this hub will hold me accountable to transparency, tracking my progress while acknowledging both my strengths and the areas I'm still developing. This will also provide good learning for other people in my current position at the time of writing this.The homelab is designed to maximize hands on learning rather than immediate practicality. Along this learning journey I will explore a plethora of topics, and already have brushed up on some fun ones. A recurring theme you will see throughout my network projects will be self-hosting, working toward a degree of digital independence and "making it harder, for the fun". Projects held within here will range from typical projects to obscure, not well documented, projects.

Below is a brief overview of current hardware being used throughout the homelab environment. Also a brief run down of everything this homelab has to offer and brief project overview so you can navigate to the area of interest. Please provide any feedback you may have all feedback is helpful and greatly appreciated.

## Project Overview
- ALR(Arch Linux Router) Project | complete-projects/ 
  ---------------------------------------------------
    - Using the Arch Linux distribution, I built out a bare-metal system into a functional daily use router for my homelab.
    - **Hardware:** HP Mini PC AK2
    - **OS:** Arch Linux
    - **Kernel:** Linux-hardened
    - **Services:** (Kea, Bind, Nftables, Systemd-networkd)
## Infrastructure Overview
- **Host Machines**:
    - **HP OMEN 25L GT12-0xxx** [Main Machine]
        - **CPU:** i7-10700F
        - **RAM:** 32GB RAM
        - **OS:** Arch Linux
        - **Kernel:** Linux 6.19.6
    - **HP Elitebook 830 G6** [Proxmox Node 1]
        - **CPU:** i5-8365U
        - **RAM:** 16GB RAM
        - **OS:** Proxmox 9.1
        - **Kernel:** 6.17.9-1-pve
    - **HP Laptop 14-ep0xxx** [Proxmox Node 2]
        - **CPU:** i3-1315U
        - **RAM:** 12GB RAM
        - **OS:** Proxmox 9.1
        - **Kernel:** Linux 6.17.9-1-pve
    - **Dell PowerEdge R720** [Proxmox Node 3]
        - **CPU:** Intel Xeon E5-2630(x2)
        - **RAM:** Reconfiguring...
        - **OS:** Proxmox 9.1
        - **Kernel:** Linux 6.17.9-1-pve
        - **Disk:** 4TB HDD
    - **Dell PowerEdge R720** [GNS3 Server]
        - **CPU:** Intel Xeon E5-2630(x2)
        - **RAM:** 164GB DDR3
        - **OS:** Ubuntu Server 25.04.4 LTS
        - **Kernel:** Linux 6.8.0-100
        - **Disk:** []
        - **Filesystem:** LVM
        - **Service(s):** (gns3)
    - **HP Mini PC AK2**
        - **CPU:** Intel Celeron J3455 
        - **RAM:** 8GB RAM
        - **OS:** Arch Linux
        - **Kernel:** Linux-lts 6.12.1
        - **Disk:** 128GB SSD (x2)
        - **FileSystem:** btrfs
        - **Service(s):** (dnsmasq, nftables, systemd-networkd)
    - **x2 Raspberry Pi 3 Model B+** 
        - **CPU:** Broadcom BCM2837
        - **RAM:** 
        - **OS:** [None]
        - **Kernel:** [None]
    - **Apple Macbook Pro A1502** [INOP] (Needs new charger)
        - **CPU:** i5-4258U 
        - **RAM:** 4GB RAM
        - **OS:** [None]
        - **Kernel:** [None]
    - **Apple MacBook Air A1466**
        - **CPU:** i5-5250U 
        - **RAM:** 8GB RAM
        - **OS:** Arch Linux
        - **Kernel:** Linux 6.17.2
    - **HP ProBook x360 435 G8** [INOP] (Wont boot up)
        - **CPU:** AMD Ryzen 3 5400U 
        - **RAM:** [None]
    - Lenovo ThinkCentre M710q [INOP]
    - HP Chromebook 14 G4 [INOP]
    - Samsung Notebook XE500C13 [INOP]
    - Dell Chromebook 11 3180 [INOP]

- **Network**:
    - Switch: [Cisco Catalyst 2960] **WS-C2960S-24PS-L**
    - Network Hub: [Netgear FS105]
    - Router:
        - [**HP Mini PC AK2**]
        - [**TP-Link Deco 6E**]
    - Access Points:
        - [Netgear Nighthawk RAX40]

- **Services**:
    - DHCP Server [dnsmasq]
    - DNS Server [dnsmasq]
    - Firewall [nftables]
    - IP Forwarding [Linux Kernel 6.12.1]

## Quick Links
- [complete-projects](./complete-projects/)
- [current-projects](./current-projects/)
- [infrastructure-design](./infrastructure-design/)
````

## Folder Structure
.
├── complete-projects
│   ├── alr-project
│   │   ├── configs
│   │   │   ├── kea
│   │   │   │   └── radius
│   │   │   ├── network
│   │   │   ├── nspawn
│   │   │   └── zonefiles.lamb.d
│   │   └── docs
│   └── par-project
├── current-projects
└── infrastructure-design
    ├── architecture
    ├── lab-notes
    ├── network
    └── services
