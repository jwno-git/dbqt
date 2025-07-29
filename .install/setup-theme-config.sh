#!/bin/bash
set -e

# Extract and setup themes
cd /home/jwno/dbqt/.icons/
tar -xf BreezeX-RosePine-Linux.tar.xz

cd /home/jwno/dbqt/.themes/
tar -xf Tokyonight-Dark.tar.xz

# Move themes to user directories
mv /home/jwno/dbqt/.icons $HOME/
mv /home/jwno/dbqt/.themes $HOME/

# Install themes system-wide
cp -r /home/jwno/.icons/BreezeX-RosePine-Linux /usr/share/icons/
cp -r /home/jwno/.themes/Tokyonight-Dark /usr/share/themes/

# Setup root configuration
mv /home/jwno/dbqt/.root/.config /root/
mv /home/jwno/dbqt/.root/tlp.conf /etc/

# Move battery toggle script
mv /home/jwno/dbqt/battery-toggle /usr/local/bin/
chmod +x /usr/local/bin/battery-toggle

# Move user configuration
mv /home/jwno/dbqt/.config $HOME/
mv /home/jwno/dbqt/.local $HOME/
# mv $HOME/dbqt/Documents $HOME/
mv /home/jwno/dbqt/Pictures $HOME/
mv /home/jwno/dbqt/.vimrc $HOME/
mv /home/jwno/dbqt/.bashrc $HOME/
mv /home/jwno/dbqt/.xinitrc $HOME/
mv /home/jwno/dbqt/.Xresources $HOME/

# Copy .bashrc and .vimrc to root directory (same files for both user and root)
sudo cp /home/jwno/.bashrc /root/
sudo cp /home/jwno/.vimrc /root/

# Make scripts executable
chmod +x /home/jwno/.local/bin/*.sh

# Configure cursor theme
sed -i 's/Adwaita/BreezeX-RosePine-Linux/g' /usr/share/icons/default/index.theme

# Cleanup
rm -rf /home/jwno/dbqt/.root

echo "Themes and configuration setup complete"
