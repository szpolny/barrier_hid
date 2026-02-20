#!/bin/bash

# Find the correct config.txt location
if [ -f "/boot/firmware/config.txt" ]; then
    CONFIG_FILE="/boot/firmware/config.txt"
elif [ -f "/boot/config.txt" ]; then
    CONFIG_FILE="/boot/config.txt"
else
    echo "Error: Could not find config.txt in /boot or /boot/firmware."
    exit 1
fi

echo "Using config file: $CONFIG_FILE"

# Remove any existing dwc2 overlay lines to start fresh and avoid conflicts like dr_mode=host
sudo sed -i '/dtoverlay=dwc2/d' "$CONFIG_FILE"

# Add the correct overlay line
echo "Adding dtoverlay=dwc2,dr_mode=peripheral to $CONFIG_FILE"
echo "dtoverlay=dwc2,dr_mode=peripheral" | sudo tee -a "$CONFIG_FILE"

# Add dwc2 to /etc/modules if not already present
if ! grep -q "^dwc2" /etc/modules; then
    echo "Adding dwc2 to /etc/modules"
    echo "dwc2" | sudo tee -a /etc/modules
else
    echo "dwc2 already exists in /etc/modules"
fi

echo "Setup complete. PLEASE REBOOT your Raspberry Pi now."
