#!/bin/bash
set -e

# Change to source directory
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
make install PREFIX=/usr/local

echo "BLE.sh installed successfully"
echo "BLE.sh is now available system-wide at /usr/local/share/blesh/ble.sh"
