#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================
# ArchSick profiledef.sh — forked from Archcraft
# Developer: lovevsick
# ============================================================

iso_name="archsick"
iso_label="ARCHSICK_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="lovevsick <https://github.com/lovevsick/archsick>"
iso_application="ArchSick Linux — Fast. Light. Developer-Ready."
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=(
    'bios.syslinux'
    'uefi-x64.grub.esp'
    'uefi-x64.grub.eltorito'
)
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-b' '1M' '-Xcompression-level' '19')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:0400"
    ["/etc/sudoers.d"]="0:0:750"
    ["/root"]="0:0:750"
    ["/root/.automated_script.sh"]="0:0:755"
    ["/root/.gnupg"]="0:0:700"
    ["/root/customize_airootfs.sh"]="0:0:755"
    ["/usr/local/bin/archsick-firstrun"]="0:0:755"
    ["/usr/local/bin/archsick-powermenu"]="0:0:755"
    ["/usr/local/bin/archsick-harden"]="0:0:755"
)
