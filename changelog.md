# ArchSick Changelog

## [Unreleased] — main branch

### Forked from Archcraft
- Full rebrand: all `archcraft` → `archsick` in identifiers, labels, metadata
- Developer credit changed to `lovevsick`

### Build system
- `profiledef.sh`: ISO name/label/publisher updated; compression upgraded to `zstd -19` (was `xz`)
- `packages.x86_64`: stripped heavy Nvidia stack from default, added C++ toolchain, Java, gaming packages, zram-generator
- `pacman.conf`: added `multilib` repo; parallel downloads → 10; removed `adi1090x` DownloadUser
- EFI entries: removed Nvidia entry; renamed all labels to ArchSick; timeout 10→3s

### Airootfs
- `hostname`: `archcraft` → `archsick`
- `motd`: ArchSick branding, lovevsick credit
- `sddm.conf`: Numlock on; added Autologin stanza; JetBrains Mono font
- `customize_airootfs.sh`: complete rewrite
  - Locale generation (en_US + vi_VN)
  - zram with zstd compression enabled by default
  - Performance sysctl (vm.swappiness=10, TCP tuning, inotify)
  - Security sysctl (rp_filter, syncookies, ASLR, kptr_restrict)
  - I/O scheduler: `none` for SSD/NVMe, `bfq` for HDD (udev rule)
  - CPU governor: `schedutil` via tmpfiles.d
  - TLP full laptop profile (performance AC, schedutil BAT)
  - AppArmor enabled on boot
  - UFW default deny incoming
  - Autostart patched: Archcraft welcome → ArchSick firstrun (Openbox + BSPWM)

### New scripts (airootfs/usr/local/bin/)
- `archsick-firstrun`: post-install wizard (yay, VSCodium + C++ config, oh-my-zsh, osu!lazer, Prism Launcher)
- `archsick-powermenu`: Rofi power menu (shutdown/reboot/suspend/lock/logout)
- `archsick-harden`: security hardening (UFW, kernel sysctl, SSH, fail2ban, file permissions)
- `archsick-update`: `pacman -Syu && yay -Syu` wrapper

### Dotfiles (skel + /etc/archsick/)
- **Openbox** `rc.xml`: 4 workspaces (DEV/WEB/GAME/MISC), Super keybinds, window snapping, app routing
- **Openbox** `autostart`: picom → tint2 → dunst → nm-applet → polkit → xss-lock → udiskie
- **Openbox** `menu.xml`: right-click menu with apps, settings, power
- **Alacritty**: Tokyo Night color scheme, JetBrains Mono 12.5px, borderless, opacity 0.92
- **Picom**: GLX backend, shadows, fading; blur disabled for iGPU performance
- **Rofi** `launcher.rasi`: dark theme, `#7dcfff` accent, border-left highlight on selection
- **Rofi** `powermenu.rasi`: narrow 240px variant
- **Tint2**: 30px bottom bar, JBM font, workspaces + tasks + systray + clock
- **Dunst**: top-right, rounded 8px, urgency colors matching theme
- **GTK3** `gtk.css`: full dark theme synchronized with terminal/rofi palette
- **Fastfetch** `config.jsonc`: ArchSick ASCII logo, cyan key colors
- **Zsh** `.zshrc`: powerlevel10k, `cpp`/`cppdebug`/`cr`/`new-cpp` dev aliases, pacman/yay aliases

### CI/CD
- `.github/workflows/build-iso.yml`: validate (xmllint + shellcheck + duplicate-package check) → build in `archlinux:latest` → QEMU smoke test → GitHub Release on `v*` tags

### Branding
- `grub/grub.cfg`: ArchSick menu labels, timeout 10→3s, `countdown` style
- `syslinux/archiso_sys.cfg`: ArchSick BIOS menu labels
- `syslinux/archiso_head.cfg`: cyan title color `#7dcfffff`
- `branding/grub/theme.txt`: ArchSick GRUB graphical theme
- `branding/ascii/logo.txt`: fastfetch ASCII logo
