#!/bin/bash
set -e

# Configure NetworkManager
sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf

# Remove motd
rm -rf /etc/motd

# Setup network interfaces
tee /etc/network/interfaces > /dev/null << 'EOF'
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback
EOF

# Enable system services
systemctl enable NetworkManager
systemctl enable tlp.service

# Enable user services
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber

echo "Network and services configured"
