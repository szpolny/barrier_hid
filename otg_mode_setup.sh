#!/bin/bash

# Find the correct config.txt location (Prioritize /boot/firmware on newer OS)
if [ -f "/boot/firmware/config.txt" ]; then
    CONFIG_FILE="/boot/firmware/config.txt"
elif [ -f "/boot/config.txt" ]; then
    CONFIG_FILE="/boot/config.txt"
else
    echo "Error: Could not find config.txt in /boot or /boot/firmware."
    exit 1
fi

echo "Using config file: $CONFIG_FILE"

# Add dtoverlay=dwc2 to config.txt if not already present
# We include dr_mode=peripheral to force gadget mode
if ! grep -q "dtoverlay=dwc2" "$CONFIG_FILE"; then
    echo "Adding dtoverlay=dwc2,dr_mode=peripheral to $CONFIG_FILE"
    echo "dtoverlay=dwc2,dr_mode=peripheral" | sudo tee -a "$CONFIG_FILE"
elif ! grep -q "dr_mode=peripheral" "$CONFIG_FILE"; then
    echo "Updating existing dwc2 overlay with dr_mode=peripheral"
    sudo sed -i 's/dtoverlay=dwc2/dtoverlay=dwc2,dr_mode=peripheral/g' "$CONFIG_FILE"
else
    echo "dtoverlay=dwc2,dr_mode=peripheral already exists in $CONFIG_FILE"
fi

# Add dwc2 to /etc/modules if not already present
if ! grep -q "^dwc2" /etc/modules; then
    echo "Adding dwc2 to /etc/modules"
    echo "dwc2" | sudo tee -a /etc/modules
else
    echo "dwc2 already exists in /etc/modules"
fi

echo "Setup complete. Please reboot your Raspberry Pi."
