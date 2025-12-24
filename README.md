# Homelab Documentation

## Quick Info
- **Location**: Home Office
- **Purpose**: Learning, Development, Self-hosting, Digital Freedom
- **Last Updated**: 2025-11-11 22:56

## Purpose
This repo documents all projects within my homelab environment and the reasoning behind them. It serves as both an overview of what's contained here and a running record of my experimentation.

This homelab portfolio exists primarily as a learning space. Projects documented here may succeed, fail, or evolve over time and all of that is fine with me. The goal is not to capture perfection, it is to capture the learning process itself and showcase it. This will also provide good learning for other people in my current position at the time of writing this.

The homelab is designed to maximize hands on learning rather than immediate practicality. Along this learning journey I will explore a plethora of topics, and already have brushed up on some fun ones. A recurring theme you will see throughout my network projects will be self-hosting, working toward a degree of digital independence and "making it harder, for the fun". Projects held within here will range from typical projects to obscure, not well documented, projects.

## Infrastructure Overview
- **Host Machines**: 
    - Lenovo Ideapad Flex 5 14ITL05 [i3-1115G4] [4GB RAM](*Arch Linux 6.17.5*)
    - HP OMEN 25L GT12-0xxx [i7-10700F] [32GB RAM](*Arch Linux 6.17.5*)
    - HP Laptop 14-ep0xxx [i3-1315U] [8GB RAM](No OS)
    - HP TinyPC [Intel Celeron J3455] [8GB RAM](*Arch Linux-lts 6.12.1*)[PAR(Project Arch Router)]
    - x2 Raspberry Pi 3 Model B+ [Broadcom BCM2837](No OS)
    - Apple Macbook Pro A1502 [i5-4258U] [4GB RAM](No OS)
    - Dell PowerEdge R720 [Intel Xeon E5-2630] [128GB RAM DDR3](*Proxmox Linux 6.17.4*)
    - Apple MacBook Air A1466 [i5-5250U] [8GB RAM](Arch Linux)
    - HP ProBook x360 435 G8 [AMD Ryzen 3 5400U] [16GB RAM](*Kali Linux 6.16.5*)
    - HP Chromebook 14 G4 [](No OS)
    - Samsung Notebook XE500C13 [](No OS)
    - Dell Chromebook 11 3180 [](No OS)
- **Network**:
    - Switch: [Cisco Catalyst 2960] **WS-C2960S-24PS-L**
    - Network Hub: [Netgear FS105]
    - Router:
        - **HP TinyPC ak2** [Intel Celeron J3455 (8GB RAM)](Arch Linux-lts 6.12.1)
        - [TP-Link Deco 6E]
    - Access Points:
        - [Netgear Nighthawk RAX40]
- **Services**:
    - DHCP Server [dnsmasq]
    - DNS Server [dnsmasq]
    - Firewall [nftables]
    - IP Forwarding [Linux Kernel 6.12.1]

## Quick Links
- [Network Diagram](./docs/network-diagram.md)
- [Hardware Inventory](./docs/hardware.md)
- [Services](./docs/services.md)
- [Procedures](./docs/procedures.md)
````

## Folder Structure

homelab-portfolio/
├── README.md                    # Main overview
├── docs/
│   ├── hardware.md             # Hardware specs
│   ├── network-diagram.md      # Network topology
│   ├── services.md             # Running services
│   ├── procedures.md           # How-to guides
│   └── troubleshooting.md      # Common issues
├── configs/
│   ├── archrouter/
│   │   └── dnsmasq.conf
│   ├── cisco-c2960/
│   │   ├── config
│   │   └── 
│   └── scripts/
│       └── sync.sh
├── projects/
│   ├── ProjectArchRouter-v0.1.md
│   └── README.md
├── diagrams/
│   └── README.md
└── changelog.md                # Changes over time

