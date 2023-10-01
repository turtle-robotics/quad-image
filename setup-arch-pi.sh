#!/bin/sh
# by Ian Lansdowne
set -e

# Get Arch ARM (aarch64) Filesystem
wget -Nq http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz

[[ -z "$device" ]] && read -p 'Device to format: ' device
[[ -z "$hostname" ]] && read -p 'Enter a hostname: ' hostname
[[ -z "$user" ]] && read -p 'New User: ' user
[[ -z "$pw" ]] && read -sp 'Password: ' pw

wipefs -abf "$device"
sfdisk "$device" < partitions.sfdisk
mkfs.vfat -I "${device}1"
mkfs.ext4 -F "${device}2"
fatlabel "${device}1" boot
e2label "${device}2" root

mkdir -p root
mount "${device}2" root
mkdir -p root/boot
mount "${device}1" root/boot
tar -xpf ArchLinuxARM-rpi-aarch64-latest.tar.gz -C root
sync
sed -i 's/mmcblk0/mmcblk1/g' root/etc/fstab # required for aarch64
sed -i "/^#Color/ cColor" /etc/pacman.conf # colors!
sed -i "/^#ParallelDownloads/ cParallelDownloads=5" /etc/pacman.conf # faster package downloads

# Modify configuration files

# Automatically connect to a Wi-Fi network
cat << EOF > root/etc/netctl/automatic-wifi
Description='A simple WPA encrypted wireless connection'
Interface=wlan0
Connection=wireless
Security=wpa
IP=dhcp
ESSID='<ssid>'
Key='<password>'
EOF

echo "$hostname" > root/etc/hostname

# Run configuration script

arch-chroot root /bin/sh << EOF
pacman-key --init
pacman-key --populate archlinuxarm

pacman -Syu --noconfirm sudo fish
pacman -Sc --noconfirm
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
visudo -c
useradd -m "$user" -s /bin/fish
echo "$user:$pw" | chpasswd
usermod -aG wheel "$user"
passwd -d root
userdel -r alarm

netctl enable automatic-wifi
EOF

umount -AR root
