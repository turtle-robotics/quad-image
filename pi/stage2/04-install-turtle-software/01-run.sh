# Copy CAN network file for systemd-networkd to read, so it can start CAN on boot
install -m 644 files/can.network "${ROOTFS_DIR}/etc/systemd/network/"

# Copy SSH config file, so you can ssh into 'robot' without a password
install -m 777 files/ssh_empty_passwords.conf "${ROOTFS_DIR}/etc/ssh/sshd_config.d/"

# Add dtoverlay to enable ethernet over USB
tee "${ROOTFS_DIR}/boot/config.txt" << EOF 
[all]
dtoverlay=dwc2,dr_mode=peripheral
EOF

tee "${ROOTFS_DIR}/boot/cmdline.txt" << "modules-load=dwc2,g_ether"