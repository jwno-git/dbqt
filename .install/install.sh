#!/bin/bash
set -e

read -p "Press Enter to continue..."

# Create source directory for builds
mkdir -p /home/jwno/src

# Move all configuration files and directories first
echo "Moving configuration files and directories..."

# Move user configuration
mv /home/jwno/dbqt/.config /home/$USER/
mv /home/jwno/dbqt/.local /home/$USER/
mv /home/jwno/dbqt/Pictures /home/$USER/
mv /home/jwno/dbqt/.vimrc /home/$USER/
mv /home/jwno/dbqt/.bashrc /home/$USER/
mv /home/jwno/dbqt/.xinitrc /home/$USER/
mv /home/jwno/dbqt/.Xresources /home/$USER/
mv /home/jwno/dbqt/.icons /home/jwno/
mv /home/jwno/dbqt/.themes /home/jwno/

sleep 0.5

# Extract and setup themes
cd /home/jwno/.icons/
if [ -f BreezeX-RosePine-Linux.tar.xz ]; then
    tar -xf BreezeX-RosePine-Linux.tar.xz
else
    echo "Error: BreezeX-RosePine-Linux.tar.xz not found"
    exit 1
fi

cd /home/jwno/.themes/
if [ -f Tokyonight-Dark.tar.xz ]; then
    tar -xf Tokyonight-Dark.tar.xz
else
    echo "Error: Tokyonight-Dark.tar.xz not found"
    exit 1
fi

# Setup root configuration
sudo mv /home/jwno/dbqt/.root/.config /root/
# sudo mv /home/jwno/dbqt/.root/tlp.conf /etc/

# Move battery toggle script
sudo mv /home/jwno/dbqt/battery-toggle /usr/local/bin/
sudo chmod +x /usr/local/bin/battery-toggle

# Copy .bashrc and .vimrc to root directory (same files for both user and root)
sudo cp /home/jwno/.bashrc /root/
sudo cp /home/jwno/.vimrc /root/

# Make scripts executable
chmod +x /home/jwno/.local/bin/*.sh

# Cleanup
# rm -rf /home/jwno/dbqt/.root

echo "Configuration files moved successfully"

# Step 1: Setup zram swap
echo "Setting up zram swap..."
# Install required packages
sudo apt update && sudo apt install -y util-linux zstd

# Load zram module
sudo modprobe zram num_devices=1

# Create systemd service
sudo tee /etc/systemd/system/zram-swap.service > /dev/null << 'EOF'
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
sudo tee /usr/local/bin/zram-swap > /dev/null << 'EOF'
#!/bin/bash
modprobe zram num_devices=1
echo zstd > /sys/block/zram0/comp_algorithm
echo 8G > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon -p 100 /dev/zram0
EOF

sudo chmod +x /usr/local/bin/zram-swap

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable zram-swap.service
sudo systemctl start zram-swap.service

echo "zram swap enabled: 8G"

sleep 0.5

# Step 2: Add Chrome repository
echo "Adding Chrome repository..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

sudo apt update
sudo apt modernize-sources -y


# Step 3: Install main packages
echo "Installing main packages..."
sudo apt install -y \
  bluez \
  brightnessctl \
  btop \
  cliphist \
  curl \
  dunst \
  fastfetch \
  fbset \
  feh \
  firefox-esr-l10n-en-ca \
  flatpak \
  fonts-font-awesome \
  fonts-hack \
  fonts-terminus \
  gawk \
  gimp \
  google-chrome-stable \
  lxpolkit \
  network-manager \
  network-manager-applet \
  nftables \
  openssh-client \
  pavucontrol \
  picom \
  pipewire \
  pipewire-pulse \
  pipewire-audio \
  pipewire-alsa \
  pkexec \
  psmisc \
  qtile \
  tar \
  tlp \
  tlp-rdw \
  unzip \
  vim \
  wget \
  x11-xserver-utils \
  xclip \
  xorg \
  xserver-xorg \
  xinit \
  zip

# Step 4: Build suckless tools
echo "Building suckless tools..."
# Install build dependencies
sudo apt install -y \
  build-essential \
  git \
  libx11-dev \
  libxft-dev \
  libxinerama-dev \
  libxext-dev \
  libxrandr-dev \
  libimlib2-dev \
  libexif-dev \
  libgif-dev \
  libpam0g-dev \
  libxmu-dev \
  pkg-config \
  make

sleep 0.5

cd /home/jwno/src

# Build ST terminal
echo "Building ST terminal..."
wget https://dl.suckless.org/st/st-0.9.2.tar.gz
tar -xzf st-0.9.2.tar.gz
cd st-0.9.2

# Download and apply patches
wget https://st.suckless.org/patches/blinking_cursor/st-blinking_cursor-20230819-3a6d6d7.diff
wget https://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff
wget https://st.suckless.org/patches/scrollback/st-scrollback-0.9.2.diff
wget https://st.suckless.org/patches/scrollback/st-scrollback-mouse-0.9.2.diff

sleep 0.5

patch -p1 < st-blinking_cursor-20230819-3a6d6d7.diff
patch -p1 < st-bold-is-not-bright-20190127-3be4cf1.diff
patch -p1 < st-scrollback-0.9.2.diff
patch -p1 < st-scrollback-mouse-0.9.2.diff

make clean
sudo make install
cd ..
tar -czf st-patched-backup.tar.gz st-0.9.2/

# Build sxiv
echo "Building sxiv..."
git clone https://github.com/xyb3rt/sxiv
cd sxiv
make clean
sudo make install
cd ..
tar -czf sxiv-backup.tar.gz sxiv/

# Build slock
echo "Building slock..."
git clone https://git.suckless.org/slock
cd slock
wget https://tools.suckless.org/slock/patches/blur-pixelated-screen/slock-blur_pixelated_screen-1.4.diff

sleep 0.5

patch -p1 < slock-blur_pixelated_screen-1.4.diff
sed -i 's/CFLAGS = /CFLAGS = -Wno-error /' Makefile
make clean
sudo make install
cd ..
tar -czf slock-patched-backup.tar.gz slock/

# Build dmenu
echo "Building dmenu..."
git clone https://git.suckless.org/dmenu
cd dmenu
wget https://tools.suckless.org/dmenu/patches/alpha/dmenu-alpha-20230110-5.2.diff

sleep 0.5

patch -p1 < dmenu-alpha-20230110-5.2.diff
make clean
sudo make install
cd ..
tar -czf dmenu-patched-backup.tar.gz dmenu/

# Cleanup downloaded archives
rm -f st-0.9.2.tar.gz

echo "Suckless tools built and installed"

# Step 5: Setup BLE.sh (Bash Line Editor)
echo "Installing BLE.sh..."
cd /home/jwno/src

# Clone BLE.sh repository
echo "Cloning BLE.sh repository..."
git clone https://github.com/akinomyoga/ble.sh.git
cd ble.sh

# Build BLE.sh
echo "Building BLE.sh..."
make

# Install system-wide to /usr/local
echo "Installing BLE.sh to /usr/local/share/blesh..."
sudo make install PREFIX=/usr/local

echo "BLE.sh installed successfully"

# Step 6: Configure qtile
echo "Configuring qtile..."
# Create qtile desktop entry
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/qtile.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=qtile start
Type=Application
Keywords=wm;tiling
EOF

# Install themes system-wide (now that themes are moved and extracted)
sudo cp -r /home/jwno/.icons/BreezeX-RosePine-Linux /usr/share/icons/
sudo cp -r /home/jwno/.themes/Tokyonight-Dark /usr/share/themes/

# Configure cursor theme
sudo sed -i 's/Adwaita/BreezeX-RosePine-Linux/g' /usr/share/icons/default/index.theme

echo "Qtile configured"

# Step 7: Install Flatpaks
echo "Installing Flatpak applications..."
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub org.flameshot.Flameshot
flatpak install -y --user flathub com.protonvpn.www
flatpak install -y --user flathub com.obsproject.Studio
flatpak install -y --user flathub org.standardnotes.standardnotes
flatpak install -y --user flathub com.discordapp.Discord
flatpak install -y --user flathub com.bitwarden.desktop
flatpak install -y --user flathub org.kde.kdenlive
flatpak install -y --user flathub com.slack.Slack

# Apply theme overrides to Flatpak applications
echo "Applying theme overrides to Flatpak applications..."
flatpak override --user --env=GTK_THEME=Tokyonight-Dark org.flameshot.Flameshot
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux org.flameshot.Flameshot
flatpak override --user --env=GTK_THEME=Tokyonight-Dark com.protonvpn.www
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux com.protonvpn.www
flatpak override --user --env=GTK_THEME=Tokyonight-Dark com.obsproject.Studio
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux com.obsproject.Studio
flatpak override --user --env=GTK_THEME=Tokyonight-Dark org.standardnotes.standardnotes
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux org.standardnotes.standardnotes
flatpak override --user --env=GTK_THEME=Tokyonight-Dark com.discordapp.Discord
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux com.discordapp.Discord
flatpak override --user --env=GTK_THEME=Tokyonight-Dark com.bitwarden.desktop
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux com.bitwarden.desktop
flatpak override --user --env=GTK_THEME=Tokyonight-Dark org.kde.kdenlive
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux org.kde.kdenlive
flatpak override --user --env=GTK_THEME=Tokyonight-Dark com.slack.Slack
flatpak override --user --env=XCURSOR_THEME=BreezeX-RosePine-Linux com.slack.Slack

# Step 8: Install systemd-boot
echo "Installing systemd-boot..."
sudo apt install -y systemd-boot
sudo bootctl install

# Remove GRUB
sudo apt purge --allow-remove-essential -y grub* shim-signed ifupdown nano os-prober vim-tiny zutty
sudo apt autoremove --purge -y

echo "Enter GRUB boot ID to delete (check efibootmgr output):"
sudo efibootmgr
read -r BOOT_ID
sudo efibootmgr -b "$BOOT_ID" -B

# Step 9: Configure network and services
echo "Configuring network and services..."
# Configure NetworkManager
sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf

# Remove motd
sudo rm -rf /etc/motd

# Setup network interfaces
sudo tee /etc/network/interfaces > /dev/null << 'EOF'
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback
EOF

# Enable system services
sudo systemctl enable NetworkManager
sudo systemctl enable tlp.service

# Enable user services
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber

echo "Network and services configured"

# Step 10: Setup nftables firewall
echo "Setting up nftables firewall..."
# Install nftables
sudo apt install -y nftables

# Create nftables configuration
sudo tee /etc/nftables.conf > /dev/null << 'EOF'
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
sudo systemctl enable nftables
sudo systemctl start nftables
sudo nft -f /etc/nftables.conf

echo "nftables firewall enabled"

echo "Installation complete!"
