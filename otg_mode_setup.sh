#!/bin/bash

# Find the correct config.txt location
CONFIG_FILE="/boot/config.txt"
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="/boot/firmware/config.txt"
fi

# Check if config.txt exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Could not find config.txt in /boot or /boot/firmware."
    exit 1
fi

# Add dtoverlay=dwc2 to config.txt if not already present
if ! grep -q "^dtoverlay=dwc2" "$CONFIG_FILE"; then
    echo "Adding dtoverlay=dwc2 to $CONFIG_FILE"
    echo "dtoverlay=dwc2" | sudo tee -a "$CONFIG_FILE"
else
    echo "dtoverlay=dwc2 already exists in $CONFIG_FILE"
fi

# Add dwc2 to /etc/modules if not already present
if ! grep -q "^dwc2" /etc/modules; then
    echo "Adding dwc2 to /etc/modules"
    echo "dwc2" | sudo tee -a /etc/modules
else
    echo "dwc2 already exists in /etc/modules"
fi

echo "Setup complete. Please reboot your Raspberry Pi."
