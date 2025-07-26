#!/bin/bash
set -e

# Install required packages
apt update && apt install -y util-linux zstd

# Load zram module
modprobe zram num_devices=1

# Create systemd service
tee /etc/systemd/system/zram-swap.service > /dev/null << 'EOF'
[Unit]
Description=zram swap
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/zram-swap
ExecStop=/sbin/swapoff /dev/zram0
TimeoutSec=30

[Install]
WantedBy=multi-user.target
EOF

# Create swap script
tee /usr/local/bin/zram-swap > /dev/null << 'EOF'
#!/bin/bash
modprobe zram num_devices=1
echo zstd > /sys/block/zram0/comp_algorithm
echo 8G > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon -p 100 /dev/zram0
EOF

chmod +x /usr/local/bin/zram-swap

# Enable and start
systemctl daemon-reload
systemctl enable zram-swap.service
systemctl start zram-swap.service

echo "zram swap enabled: 8G"
