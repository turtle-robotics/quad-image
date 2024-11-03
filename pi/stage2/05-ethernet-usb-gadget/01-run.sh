install -m 644 files/etc.dnsmasq.d.usb0 "${ROOTFS_DIR}/etc/dnsmasq.d/usb0"
install -m 644 files/etc.network.interfaces.d.usb0 "${ROOTFS_DIR}/etc/network/interfaces.d/usb0"

# Add dtoverlay to enable ethernet over USB
tee -a "${ROOTFS_DIR}/boot/firmware/config.txt" << EOF
dtoverlay=dwc2,dr_mode=peripheral
EOF

sed -i 's/rootwait/rootwait modules-load=dwc2,g_ether/g' "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

tee -a "${ROOTFS_DIR}/etc/dhcpcd.conf" << EOF
denyinterfaces usb0
EOF