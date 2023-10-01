#!/bin/sh
# by Ian Lansdowne
set -e

hostname='quad1'
ssid='TURTLE QUAD V1'
user='robot'
pw='robot'

# Get Arch ARM (aarch64) Filesystem
wget -Nq http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz

[[ -z "$device" ]] && read -p 'Device to format: ' device
[[ -z "$hostname" ]] && read -p 'Enter a hostname: ' hostname
[[ -z "$ssid" ]] && read -sp 'Enter a ssid: ' ssid
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

# Create a dhcp server on wlan0
cat << EOF > root/etc/systemd/network/wlan0.network
[Match]
Name=wlan0

[Network]
Address=10.1.1.1/24
DHCPServer=true

[DHCPServer]
PoolOffset=100
PoolSize=20
EmitDNS=yes
DNS=9.9.9.9
EOF

echo "$hostname" > root/etc/hostname

# Run configuration script

arch-chroot root /bin/sh << EOF
pacman-key --init
pacman-key --populate archlinuxarm

pacman -Syu --noconfirm sudo fish base-devel vim man cmake eigen
pacman -Sc --noconfirm
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
visudo -c
useradd -m "$user" -s /bin/fish
echo "$user:$pw" | chpasswd
usermod -aG wheel "$user"
passwd -d root
userdel -r alarm

systemctl enable hostapd systemd-networkd
EOF

# Modify more configuration files, now that all packages are installed

cat << EOF > root/etc/hostapd/hostapd.conf
interface=wlan0
ssid=$ssid
driver=nl80211
country_code=US
channel=acs_survey
EOF

cat << EOF > root/etc/systemd/system/hostapd.service.d/override.conf
[Unit]
BindsTo=sys-subsystem-net-devices-wlan0.device
After=sys-subsystem-net-devices-wlan0.device
EOF

umount -AR root
