#!/bin/bash
set -e

read -p "Press Enter to continue..."

# Make all scripts executable
chmod +x $HOME/dbqt/.install/*.sh

# Step 1: Setup zram swap
echo "Setting up zram swap..."
sudo $HOME/dbqt/.install/setup-zram.sh

# Step 2: Add Chrome repository
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
  curl \
  dunst \
  fastfetch \
  fbset \
  firefox-esr-l10n-en-ca \
  fonts-font-awesome \
  fonts-hack \
  fonts-terminus \
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
  tar \
  tlp \
  tlp-rdw \
  unzip \
  vim \
  wget \
  x11-xserver-utils \
  xorg \
  xserver-xorg \
  xinit \
  zip

# Step 4: Build suckless tools
echo "Building suckless tools..."
sudo $HOME/dbqt/.install/setup-suckless.sh

# Step 5: Build qtile
echo "Installing qtile..."
sudo $HOME/dbqt/.install/setup-qtile.sh

# Step 6: Setup themes and configuration
echo "Setting up themes and configuration..."
sudo $HOME/dbqt/.install/setup-theme-config.sh

# Step 7: Install systemd-boot
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

# Step 8: Configure network and services
echo "Configuring network and services..."
sudo $HOME/dbqt/.install/network-services-setup.sh

# Step 9: Setup nftables firewall
echo "Setting up nftables firewall..."
sudo $HOME/dbqt/.install/setup-nftables.sh

echo "Installation complete!"
