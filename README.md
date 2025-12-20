# Homelab Documentation

## Quick Info
- **Location**: Home Office
- **Purpose**: Learning, Development, Self-hosting, Digital Freedom
- **Last Updated**: 2025-11-11 22:56

## Infrastructure Overview
- **Host Machines**: 
    - Lenovo Ideapad Flex 5 14ITL05 [i3-1115G4] [4GB RAM](*Arch Linux-lts 6.12.1*)
    - HP OMEN 25L GT12-0xxx [i7-10700F] [32GB RAM](*Arch Linux 6.17.5*)
    - HP Laptop 14-ep0xxx [i3-1315U] [8GB RAM](No OS)
    - HP TinyPC [Intel Celeron J3455] [8GB RAM](*Arch Linux-lts 6.12.1*)[PAR(Project Arch Router)]
    - x2 Raspberry Pi 3 Model B+ [Broadcom BCM2837](No OS)
    - Apple Macbook Pro A1502 [i5-4258U] [4GB RAM](No OS)
    - Dell PowerEdge R720 [Intel Xeon E5-2630] [128GB RAM DDR3](*Arch Linux-lts 6.12.1*)
    - Apple MacBook Air A1466 [i5-5250U] [8GB RAM](Arch Linux)
    - HP ProBook x360 435 G8 [AMD Ryzen 3 5400U] [16GB RAM](*Gentoo Linux 6.17.5*)
    - HP Chromebook 14 G4 [](No OS)
    - Samsung Notebook XE500C13 [](No OS)
    - Dell Chromebook 11 3180 [](No OS)
- **Network**:
    - Switch: [Cisco Catalyst 2960] **WS-C2960S-24PS-L**
    - Network Hub: [Netgear FS105]
    - Router:
        - HP TinyPC ak2 [Arch Linux] # fully configured linux router from the Arch distrobution
        - [Netgear Nighthawk RAX40]
        - [TP-Link Deco 6E]
- **Services**:
    - DHCP Server [dnsmasq]
    - DNS Server [dnsmasq]
    - Firewall [nftables]
    - IP Forwarding [nftables + systemd-networkd]

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
│   ├── hyprland/
│   │   └── hyprland.conf
│   ├── waybar/
│   │   ├── config
│   │   └── style.css
│   └── scripts/
│       └── sync.sh
├── diagrams/
│   └── network.png
└── changelog.md                # Changes over time

