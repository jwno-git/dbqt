#!/bin/bash
set -e

# Install nftables
apt install -y nftables

# Create nftables configuration
tee /etc/nftables.conf > /dev/null << 'EOF'
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;
        iif "lo" accept
        ct state established,related accept
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
        udp sport 67 udp dport 68 accept
        udp sport 53 accept
        tcp sport 53 accept
        udp sport 123 accept
        counter drop
    }
    
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
    
    chain output {
        type filter hook output priority filter; policy accept;
    }
}
EOF

# Enable and start
systemctl enable nftables
systemctl start nftables
nft -f /etc/nftables.conf

echo "nftables firewall enabled"
