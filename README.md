<div align="center">
<img src="https://raw.githubusercontent.com/lovevsick/archsick/main/assets/logo.png" alt="ArchSick" width="120"/>

# ArchSick

**Fast. Light. Developer-Ready.**

[![Build ISO](https://github.com/lovevsick/archsick/actions/workflows/build-iso.yml/badge.svg)](https://github.com/lovevsick/archsick/actions/workflows/build-iso.yml)
[![License](https://img.shields.io/badge/license-GPL--2.0-blue)](LICENSE)
![Arch Based](https://img.shields.io/badge/based_on-Arch_Linux-1793D1?logo=arch-linux)

*An Arch Linux distribution forked from [Archcraft](https://github.com/archcraft-os/archcraft) — rebuilt, rebranded, and aggressively optimised for low-end hardware.*

**Developer: [lovevsick](https://github.com/lovevsick)**

</div>

---

## What is ArchSick?

ArchSick is a complete Arch-based OS targeting **developers, students, gamers, and daily users** on 4–8 GB RAM machines with Intel/AMD integrated graphics. It delivers a fast, lean desktop that's ready for C++ development, gaming (osu!lazer, Minecraft), and everyday computing out of the box.

## Performance targets

| Metric       | Target         |
|--------------|----------------|
| Idle RAM     | 200 – 450 MB   |
| Idle CPU     | 0 – 2%         |
| Boot (SSD)   | < 10 s         |
| Disk size    | < 8 GB         |

## Hardware focus

- Intel HD / UHD / Iris Xe Graphics
- AMD Radeon iGPU (Vega, RDNA)
- 4 GB and 8 GB RAM systems
- SSD and HDD storage
- Older laptops (2012+)

## Default stack

| Layer           | Application                     |
|-----------------|---------------------------------|
| Window manager  | Openbox (BSPWM optional)        |
| Compositor      | Picom (GLX, minimal config)     |
| Display manager | SDDM                            |
| Terminal        | Alacritty                       |
| Shell           | Zsh + powerlevel10k             |
| Launcher        | Rofi                            |
| Panel           | Tint2                           |
| Notifications   | Dunst                           |
| Audio           | PipeWire                        |
| Editor          | VSCodium + Nano                 |
| File manager    | Thunar                          |

## C++ development (zero extra setup)

```bash
# Works immediately after installation
g++ -std=c++17 main.cpp -o app

# Quick compile + run shortcut
cr main.cpp

# New C++17 CMake project
new-cpp myproject
cd myproject && cmake -B build -G Ninja && cmake --build build
```

VSCodium pre-configured with:
- C/C++ extension, CMake Tools, GitLens, ErrorLens
- GCC/G++ toolchain, C++17 default standard
- JetBrains Mono 14px, dark theme

## Gaming

```bash
gamemoderun osu              # osu!lazer
gamemoderun prismlauncher    # Minecraft Java
```

Steam, Lutris, Wine, MangoHud, GameMode, DXVK, VKD3D all included.

## Key bindings

| Key                   | Action                    |
|-----------------------|---------------------------|
| `Super + Enter`       | Terminal (Alacritty)      |
| `Super + Space`       | App launcher (Rofi)       |
| `Super + E`           | File manager (Thunar)     |
| `Super + Q`           | Close window              |
| `Super + F`           | Toggle maximise           |
| `Super + Left/Right`  | Snap to half-screen       |
| `Super + 1–4`         | Switch workspace          |
| `Super + Shift + Q`   | Power menu                |
| `Print`               | Screenshot (full)         |
| `Super + Print`       | Screenshot (selection)    |

## Build

```bash
# Prerequisites: archiso
sudo pacman -S archiso

# Clone
git clone https://github.com/lovevsick/archsick
cd archsick

# Build ISO (~15–20 min)
sudo mkarchiso -v -w /tmp/archsick-work -o /tmp/out profile/

# Flash to USB
sudo dd if=/tmp/out/archsick-*.iso of=/dev/sdX bs=4M status=progress
```

CI/CD via GitHub Actions builds and releases the ISO automatically on every push to `main` and on tags `v*.*.*`.

## Repository structure

```
archsick/  (forked from archcraft-os/archcraft)
├── profile/
│   ├── profiledef.sh              # ISO identity (name, publisher, compression)
│   ├── packages.x86_64            # Full package list
│   ├── pacman.conf                # Repos: archcraft + multilib + archsick (future)
│   ├── grub/grub.cfg              # GRUB boot menu
│   ├── efiboot/                   # systemd-boot EFI entries
│   ├── syslinux/                  # BIOS syslinux menu
│   └── airootfs/
│       ├── root/customize_airootfs.sh   # Chroot build script
│       ├── etc/
│       │   ├── hostname           # archsick
│       │   ├── locale.conf        # en_US.UTF-8
│       │   ├── motd               # ArchSick welcome
│       │   ├── sddm.conf          # Login manager config
│       │   ├── sysctl.d/          # Performance + security sysctl
│       │   ├── udev/rules.d/      # I/O scheduler (SSD=none, HDD=bfq)
│       │   ├── tmpfiles.d/        # CPU governor (schedutil)
│       │   ├── systemd/           # zram-generator.conf
│       │   ├── archsick/          # System-wide default dotfiles
│       │   │   ├── openbox/       # rc.xml
│       │   │   ├── picom/         # picom.conf
│       │   │   ├── rofi/          # launcher.rasi, powermenu.rasi
│       │   │   ├── alacritty/     # alacritty.toml
│       │   │   └── fastfetch/     # config.jsonc
│       │   └── skel/.config/      # Per-user dotfiles (copied on login)
│       │       ├── openbox/       # rc.xml, autostart, menu.xml
│       │       ├── picom/
│       │       ├── rofi/
│       │       ├── alacritty/
│       │       ├── fastfetch/
│       │       ├── dunst/
│       │       ├── tint2/
│       │       └── gtk-3.0/
│       └── usr/local/bin/
│           ├── archsick-firstrun  # Post-install: yay, VSCodium, osu, MC
│           ├── archsick-powermenu # Rofi power menu
│           ├── archsick-harden    # Security hardening script
│           └── archsick-update    # pacman + yay update wrapper
└── .github/workflows/
    └── build-iso.yml              # CI/CD: build → test → release
```

## License

GPL-2.0 — same as Archcraft / Arch Linux.  
Branding assets © lovevsick — All Rights Reserved.

---

<div align="center">
<sub>ArchSick is not affiliated with Archcraft or Arch Linux.</sub>
</div>
