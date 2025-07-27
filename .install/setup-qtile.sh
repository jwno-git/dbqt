#!/bin/bash
set -e

# Install qtile dependencies
apt update
apt install -y \
  python3 \
  python3-pip \
  python3-dev \
  python3-setuptools \
  python3-wheel \
  python3-cffi \
  python3-xcffib \
  libpangocairo-1.0-0 \
  libcairo-gobject2 \
  libgtk-3-0 \
  libgdk-pixbuf2.0-0 \
  python3-gi \
  python3-gi-cairo \
  gir1.2-gtk-3.0

# Upgrade pip
python3 -m pip install --upgrade pip

# Install qtile system-wide
pip install qtile

# Create qtile desktop entry
mkdir -p /usr/share/xsessions
tee /usr/share/xsessions/qtile.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=qtile start
Type=Application
Keywords=wm;tiling
EOF

echo "Qtile installed and configured"
