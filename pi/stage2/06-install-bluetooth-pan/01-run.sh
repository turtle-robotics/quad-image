install -m 644 files/pan0.netdev "${ROOTFS_DIR}/etc/systemd/network/pan0.netdev"
install -m 644 files/pan0.network "${ROOTFS_DIR}/etc/systemd/network/pan0.network"
install -m 644 files/bt-agent.service "${ROOTFS_DIR}/etc/systemd/system/bt-agent.service"
install -m 644 files/bt-network.service "${ROOTFS_DIR}/etc/systemd/system/bt-network.service"
install -m 644 files/main.conf "${ROOTFS_DIR}/etc/bluetooth/main.conf"

# Enable Bluetooth PAN
on_chroot << EOF
systemctl enable systemd-networkd systemd-resolved bluetooth bt-agent bt-network
EOF