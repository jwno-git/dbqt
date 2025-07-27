#!/bin/bash
set -e

# Install build dependencies
apt update
apt install -y \
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

# Create source directory
mkdir -p $HOME/.local/src
cd $HOME/.local/src

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

patch -p1 < st-blinking_cursor-20230819-3a6d6d7.diff
patch -p1 < st-bold-is-not-bright-20190127-3be4cf1.diff
patch -p1 < st-scrollback-0.9.2.diff
patch -p1 < st-scrollback-mouse-0.9.2.diff

make clean install
cd ..
tar -czf st-patched-backup.tar.gz st-0.9.2/

# Build sxiv
echo "Building sxiv..."
git clone https://github.com/xyb3rt/sxiv
cd sxiv
make clean install
cd ..
tar -czf sxiv-backup.tar.gz sxiv/

# Build slock
echo "Building slock..."
git clone https://git.suckless.org/slock
cd slock
wget https://tools.suckless.org/slock/patches/blur-pixelated-screen/slock-blur_pixelated_screen-1.4.diff
patch -p1 < slock-blur_pixelated_screen-1.4.diff
make clean install
cd ..
tar -czf slock-patched-backup.tar.gz slock/

# Build dmenu
echo "Building dmenu..."
git clone https://git.suckless.org/dmenu
cd dmenu
wget https://tools.suckless.org/dmenu/patches/alpha/dmenu-alpha-20230110-5.2.diff
patch -p1 < dmenu-alpha-20230110-5.2.diff
make clean install
cd ..
tar -czf dmenu-patched-backup.tar.gz dmenu/

# Cleanup downloaded archives
rm -f st-0.9.2.tar.gz

echo "Suckless tools built and installed"
echo "Backup archives created:"
echo "  - st-patched-backup.tar.gz"
echo "  - sxiv-backup.tar.gz" 
echo "  - slock-patched-backup.tar.gz"
echo "  - dmenu-patched-backup.tar.gz"
