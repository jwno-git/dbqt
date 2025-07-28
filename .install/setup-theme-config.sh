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
mv $HOME/dbqt/.root/.config /root/
mv $HOME/dbqt/.root/tlp.conf /etc/

# Move battery toggle script
mv $HOME/dbqt/battery-toggle /usr/local/bin/
chmod +x /usr/local/bin/battery-toggle

# Move user configuration
mv $HOME/dbqt/.config $HOME/
mv $HOME/dbqt/.local $HOME/
mv $HOME/dbqt/Documents $HOME/
mv $HOME/dbqt/Pictures $HOME/
mv $HOME/dbqt/.vimrc $HOME/
mv $HOME/dbqt/.bashrc $HOME/
mv $HOME/dbqt/.xinitrc $HOME/
mv $HOME/dbqt/.Xresources $HOME/

# Copy .bashrc and .vimrc to root directory (same files for both user and root)
sudo cp $HOME/.bashrc /root/
sudo cp $HOME/.vimrc /root/

# Make scripts executable
chmod +x $HOME/.local/bin/*.sh

# Configure cursor theme
sed -i 's/Adwaita/BreezeX-RosePine-Linux/g' /usr/share/icons/default/index.theme

# Cleanup
rm -rf $HOME/dbqt/.root

echo "Themes and configuration setup complete"
