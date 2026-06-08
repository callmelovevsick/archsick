#!/usr/bin/env bash
# ============================================================
# ArchSick customize_airootfs.sh
# Runs inside chroot during mkarchiso build
# Forked from Archcraft — fully rebranded for ArchSick
# Developer: lovevsick
# ============================================================
set -e -u

## ── mkinitcpio: enable plymouth + zstd ──────────────────────
sed -i '/etc/mkinitcpio.conf' \
    -e "s/microcode/microcode plymouth/g" \
    -e "s/#COMPRESSION=\"zstd\"/COMPRESSION=\"zstd\"/g"

## Fix initrd preset for installed system
cat > "/etc/mkinitcpio.d/linux.preset" << '_EOF_'
# mkinitcpio preset — ArchSick linux
ALL_kver="/boot/vmlinuz-linux"
ALL_config="/etc/mkinitcpio.conf"
PRESETS=('default' 'fallback')
default_image="/boot/initramfs-linux.img"
fallback_image="/boot/initramfs-linux-fallback.img"
fallback_options="-S autodetect"
_EOF_

## Remove ISO-specific mkinitcpio fragments
rm -rf /etc/mkinitcpio.conf.d
rm -rf /etc/mkinitcpio.d/linux-nvidia.preset

## ── Locale & timezone ────────────────────────────────────────
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

## ── pacman: parallel downloads + archcraft + multilib ────────
sed -i 's|#ParallelDownloads.*|ParallelDownloads = 10|g' /etc/pacman.conf
sed -i 's|^Color|Color|g;s|^#Color|Color|g' /etc/pacman.conf
sed -i 's|^#VerbosePkgLists|VerbosePkgLists|g' /etc/pacman.conf
# Remove old adi1090x DownloadUser if present
sed -i '/^DownloadUser = adi1090x/d' /etc/pacman.conf

## Append repos (idempotent-ish)
grep -q '\[archcraft\]' /etc/pacman.conf || cat >> "/etc/pacman.conf" << '_EOL_'

[archcraft]
SigLevel = Optional TrustAll
Include = /etc/pacman.d/archcraft-mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
_EOL_

## ── Default shell → zsh ──────────────────────────────────────
sed -i 's#SHELL=.*#SHELL=/bin/zsh#g' /etc/default/useradd

## ── Live user ────────────────────────────────────────────────
useradd -m -G wheel,audio,video,optical,storage,games,power,input \
    -s /bin/zsh liveuser 2>/dev/null || true
echo "liveuser:liveuser" | chpasswd
echo "root:archsick" | chpasswd

## sudoers
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/02_g_wheel

## ── Enable / disable services ────────────────────────────────
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable bluetooth
systemctl enable tlp
systemctl enable acpid
systemctl enable cups
systemctl enable fstrim.timer
systemctl enable ufw
systemctl enable systemd-timesyncd
systemctl enable zram-generator 2>/dev/null || true
systemctl enable apparmor 2>/dev/null || true

systemctl disable avahi-daemon 2>/dev/null || true
systemctl disable ModemManager  2>/dev/null || true
systemctl mask debug-shell.service 2>/dev/null || true

## ── zram ─────────────────────────────────────────────────────
cat > /etc/systemd/zram-generator.conf << '_EOF_'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
_EOF_

## ── sysctl performance + security ───────────────────────────
cat > /etc/sysctl.d/99-archsick.conf << '_EOF_'
# ArchSick sysctl — performance + security
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 1500
vm.overcommit_memory = 1
kernel.nmi_watchdog = 0
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_tw_reuse = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_syncookies = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
kernel.randomize_va_space = 2
fs.suid_dumpable = 0
_EOF_

## ── CPU schedutil governor ───────────────────────────────────
cat > /etc/tmpfiles.d/cpu-governor.conf << '_EOF_'
w /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor - - - - schedutil
_EOF_

## ── I/O scheduler: none for SSD, bfq for HDD ────────────────
cat > /etc/udev/rules.d/60-ioscheduler.rules << '_EOF_'
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
_EOF_

## ── TLP laptop power ─────────────────────────────────────────
cat > /etc/tlp.conf << '_EOF_'
TLP_ENABLE=1
TLP_DEFAULT_MODE=AC
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=schedutil
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=low-power
WIFI_PWR_ON_BAT=on
WIFI_PWR_ON_AC=off
USB_AUTOSUSPEND=1
RUNTIME_PM_ON_AC=auto
RUNTIME_PM_ON_BAT=auto
_EOF_

## ── AppArmor on boot ─────────────────────────────────────────
sed -i 's/vt.global_cursor_default=0/vt.global_cursor_default=0 lsm=landlock,lockdown,yama,integrity,apparmor,bpf/g' \
    /etc/default/grub 2>/dev/null || true

## ── GRUB timeout ─────────────────────────────────────────────
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub 2>/dev/null || true

## ── UFW defaults ─────────────────────────────────────────────
ufw default deny incoming  2>/dev/null || true
ufw default allow outgoing 2>/dev/null || true

## ── Copy skel configs into /root ─────────────────────────────
rdir="/root/.config"
sdir="/etc/skel"
mkdir -p "$rdir"

rconfig=(geany gtk-3.0 Kvantum neofetch qt5ct qt6ct ranger Thunar xfce4
         openbox picom rofi alacritty fastfetch dunst tint2)
for cfg in "${rconfig[@]}"; do
    [[ -e "$sdir/.config/$cfg" ]] && cp -rf "$sdir/.config/$cfg" "$rdir/"
done

rcfg=('.gtkrc-2.0' '.oh-my-zsh' '.vim_runtime' '.vimrc' '.zshrc')
for cfile in "${rcfg[@]}"; do
    [[ -e "$sdir/$cfile" ]] && cp -rf "$sdir/$cfile" /root/
done

## ── Fix cursor ───────────────────────────────────────────────
rm -rf /usr/share/icons/default

## ── Replace autostart: Archcraft welcome → ArchSick firstrun ─
# openbox
if [[ -f /etc/skel/.config/openbox/autostart ]]; then
    sed -i -e '/## Welcome-App-Run-Once/Q' /etc/skel/.config/openbox/autostart
    cat >> "/etc/skel/.config/openbox/autostart" << '_EOL_'
## ArchSick-Firstrun-Once
if [[ ! -f "$HOME/.local/share/archsick/.firstrun-done" ]]; then
    (sleep 4 && alacritty -T "ArchSick First Run" -e archsick-firstrun) &
    sed -i '/## ArchSick-Firstrun-Once/,/^$/d' "$HOME/.config/openbox/autostart"
fi
_EOL_
fi

# bspwm
if [[ -f /etc/skel/.config/bspwm/bspwmrc ]]; then
    sed -i -e '/## Welcome-App-Run-Once/Q' /etc/skel/.config/bspwm/bspwmrc
    cat >> "/etc/skel/.config/bspwm/bspwmrc" << '_EOL_'
## ArchSick-Firstrun-Once
if [[ ! -f "$HOME/.local/share/archsick/.firstrun-done" ]]; then
    (sleep 4 && alacritty -T "ArchSick First Run" -e archsick-firstrun) &
    sed -i '/## ArchSick-Firstrun-Once/,/^$/d' "$HOME/.config/bspwm/bspwmrc"
fi
_EOL_
fi

## ── XDG user dirs ────────────────────────────────────────────
chmod +x /etc/skel/.screenlayout/my-layout.sh 2>/dev/null || true
runuser -l liveuser -c 'xdg-user-dirs-update'      2>/dev/null || true
runuser -l liveuser -c 'xdg-user-dirs-gtk-update'  2>/dev/null || true
xdg-user-dirs-update
xdg-user-dirs-gtk-update

## ── Hide unnecessary .desktop entries ────────────────────────
adir="/usr/share/applications"
apps=(avahi-discover.desktop bssh.desktop bvnc.desktop echomixer.desktop
    envy24control.desktop exo-preferred-applications.desktop feh.desktop
    hdajackretask.desktop hdspconf.desktop hdspmixer.desktop hwmixvolume.desktop
    lftp.desktop libfm-pref-apps.desktop lxshortcut.desktop lstopo.desktop
    networkmanager_dmenu.desktop nm-connection-editor.desktop
    pcmanfm-desktop-pref.desktop qv4l2.desktop qvidcap.desktop
    stoken-gui.desktop stoken-gui-small.desktop thunar-bulk-rename.desktop
    thunar-settings.desktop thunar-volman-settings.desktop yad-icon-browser.desktop)

for app in "${apps[@]}"; do
    [[ -e "$adir/$app" ]] && sed -i '$s/$/\nNoDisplay=true/' "$adir/$app"
done

## ── Remove gnome backgrounds ─────────────────────────────────
[[ -d /usr/share/backgrounds/gnome ]] && rm -rf /usr/share/backgrounds/gnome

echo "==> archsick: customize_airootfs.sh complete"
