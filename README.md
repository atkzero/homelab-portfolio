# Homelab Documentation

## Quick Info
- **Location**: Home Office
- **Purpose**: Learning, Development, Self-hosting, Digital Freedom
- **Last Updated**: 2025-11-11 22:56

## Infrastructure Overview
- **Host Machines**: 
    - Lenovo Ideapad Flex 5 14ITL05 [i3-1115G4](*Arch Linux 6.17.5*)
    - HP OMEN 25L GT12-0xxx [i7-10700F](*Arch Linux 6.17.5*)
    - HP Laptop 14-ep0xxx [i3-1315U](Proxmox 9.0.11)
    - HP TinyPC [Intel Celeron J3455](Proxmox 9.0.11)
    - x2 Raspberry Pi 3 Model B+ [Broadcom BCM2837](Nothing is running)
    - Apple Macbook Pro A1502 [i5-4258U](Nothing is running)
    - Dell PowerEdge R720 [Intel Xeon E5-2630](Proxmox 9.0.11)
- **Network**:
    - Switch: [Cisco Catalyst 2960] **WS-C2960S-24PS-L**
    - Network Hub: [Netgear FS105]
    - Router: 
        - [Netgear Nighthawk RAX40]
        - [TP-Link Deco 6E]
- **Services**:
    - (None so far)

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

