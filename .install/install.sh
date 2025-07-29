#!/bin/bash
set -e

read -p "Press Enter to continue..."

# Make all scripts executable
chmod +x /home/jwno/dbqt/.install/*.sh

# Create source directory for builds
mkdir -p /home/jwno/src

# Step 1: Setup zram swap
echo "Setting up zram swap..."
sudo /home/jwno/dbqt/.install/setup-zram.sh

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
  xclip \
  xorg \
  xserver-xorg \
  xinit \
  zip

# Step 4: Setup themes and configuration
echo "Setting up themes and configuration..."
sudo /home/jwno/dbqt/.install/setup-theme-config.sh

# Step 5: Build suckless tools
echo "Building suckless tools..."
sudo /home/jwno/dbqt/.install/setup-suckless.sh

# Step 6: Setup BLE.sh (Bash Line Editor)
echo "Installing BLE.sh..."
sudo /home/jwno/dbqt/.install/setup-ble.sh

# Step 7: Build qtile
echo "Installing qtile..."
sudo /home/jwno/dbqt/.install/setup-qtile.sh

# Step 8: Install Flatpaks
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

# Step 8: Setup themes and configuration
echo "Setting up themes and configuration..."
sudo /home/jwno/dbqt/.install/setup-theme-config.sh

# Step 9: Install systemd-boot
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

# Step 10: Configure network and services
echo "Configuring network and services..."
sudo /home/jwno/dbqt/.install/network-services-setup.sh

# Step 11: Setup nftables firewall
echo "Setting up nftables firewall..."
sudo /home/jwno/dbqt/.install/setup-nftables.sh

echo "Installation complete!"
