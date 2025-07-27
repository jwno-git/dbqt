#!/bin/bash

# Set brightness to 100% before desktop starts
brightnessctl set 100%

# Set Volume upon Launch
wpctl set-volume @DEFAULT_SINK@ 0%

# Trigger monitor setup
~/.local/bin/monitor-config.sh &

# Screen saver settings
xset s 1000    # Set screensaver timeout to 1000 seconds
xset -dpms     # Disable DPMS (Display Power Management Signaling)

# Load X11 resources
xrdb ~/.Xresources

# Enable touchpad tap-to-click
xinput set-prop 12 "libinput Tapping Enabled" 1
xinput set-prop 12 "libinput Tapping Button Mapping Enabled" 1 1

# Start picom compositor
picom --backend glx &

# Start the window manager (must be last)
exec qtile start
