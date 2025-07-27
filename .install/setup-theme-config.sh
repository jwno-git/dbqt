#!/bin/bash
set -e

# Extract and setup themes
cd $HOME/dbqt/.icons/
tar -xf BreezeX-RosePine-Linux.tar.xz

cd $HOME/dbqt/.themes/
tar -xf Tokyonight-Dark.tar.xz

# Move themes to user directories
mv $HOME/dbqt/.icons $HOME/
mv $HOME/dbqt/.themes $HOME/

# Install themes system-wide
cp -r $HOME/.icons/BreezeX-RosePine-Linux /usr/share/icons/
cp -r $HOME/.themes/Tokyonight-Dark /usr/share/themes/

# Setup root configuration
mkdir -p /root/.src
mv $HOME/dbqt/.root/.config /root/
mv $HOME/dbqt/.root/.vimrc /root/
mv $HOME/dbqt/.root/debianroot.png /root/
mv $HOME/dbqt/.root/tlp.conf /etc/

# Move user configuration
mv $HOME/dbqt/.config $HOME/
mv $HOME/dbqt/.local $HOME/
mv $HOME/dbqt/Documents $HOME/
mv $HOME/dbqt/Pictures $HOME/
mv $HOME/dbqt/.vimrc $HOME/
mv $HOME/dbqt/.bashrc $HOME/
mv $HOME/dbqt/bookmarks.html $HOME/
cp $HOME/.bashrc /root/

# Make scripts executable
chmod +x $HOME/.local/scripts/*.sh

# Configure cursor theme
sed -i 's/Adwaita/BreezeX-RosePine-Linux/g' /usr/share/icons/default/index.theme

# Cleanup
rm -rf $HOME/dbqt/.root

echo "Themes and configuration setup complete"
