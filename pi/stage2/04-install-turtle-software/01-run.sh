# Copy CAN network file for systemd-networkd to read, so it can start CAN on boot
install -m 644 files/can.network "${ROOTFS_DIR}/etc/systemd/network/"

# Copy SSH config file, so you can ssh into 'robot' without a password
install -m 777 files/ssh_empty_passwords.conf "${ROOTFS_DIR}/etc/ssh/sshd_config.d/"

install -m 644 files/etc.dnsmasq.d.usb0 "${ROOTFS_DIR}/etc/dnsmasq.d/usb0"
install -m 644 files/etc.network.interfaces.d.usb0 "${ROOTFS_DIR}/etc/network/interfaces.d/usb0"

# Add dtoverlay to enable ethernet over USB
tee -a "${ROOTFS_DIR}/boot/firmware/config.txt" << EOF
dtoverlay=dwc2,dr_mode=peripheral
EOF

echo "modules-load=dwc2,g_ether" >> "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

tee -a "${ROOTFS_DIR}/etc/dhcpcd.conf" << EOF
denyinterfaces usb0
EOF