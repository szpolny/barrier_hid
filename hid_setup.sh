#!/bin/bash
# This script sets up the USB HID gadget on a Raspberry Pi Zero W / Zero 2 W.
# It requires the dwc2 driver to be loaded (see otg_mode_setup.sh).

SRC="$(cd "$(dirname "$0")" ; pwd)"

# Ensure we are running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Try 'sudo $0'"
   exit 1
fi

# Load the libcomposite module
modprobe libcomposite

# Check if configfs is mounted
if [ ! -d /sys/kernel/config/usb_gadget ]; then
    echo "Error: USB gadget configfs not found. Is your kernel configured for gadgets?"
    exit 1
fi

cd /sys/kernel/config/usb_gadget/

# If the gadget already exists, we might need to remove it or skip
if [ -d g1 ]; then
    echo "Gadget g1 already exists. Attempting to re-enable..."
    # If bound to a UDC, unbind it first
    if [ -f g1/UDC ]; then
        echo "" > g1/UDC 2>/dev/null
    fi
else
    mkdir -p g1
fi

cd g1

# Define device identifiers
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2

# Define device strings
mkdir -p strings/0x409
echo "314159" > strings/0x409/serialnumber
echo "karepiu" > strings/0x409/manufacturer
echo "Raspberry Pi HID Proxy" > strings/0x409/product

# Set up HID Mouse function
A_N="mouse"
mkdir -p functions/hid.$A_N
echo 0 > functions/hid.$A_N/protocol
echo 0 > functions/hid.$A_N/subclass
echo 6 > functions/hid.$A_N/report_length
if [ -f "$SRC/mouse.desc" ]; then
    cat "$SRC/mouse.desc" > functions/hid.$A_N/report_desc
else
    echo "Warning: mouse.desc not found at $SRC/mouse.desc"
fi

# Set up HID Keyboard function
B_N="keyboard"
mkdir -p functions/hid.$B_N
echo 1 > functions/hid.$B_N/protocol
echo 1 > functions/hid.$B_N/subclass
echo 8 > functions/hid.$B_N/report_length
if [ -f "$SRC/keyboard.desc" ]; then
    cat "$SRC/keyboard.desc" > functions/hid.$B_N/report_desc
else
    echo "Warning: keyboard.desc not found at $SRC/keyboard.desc"
fi

# Set up HID Touch function
C_N="touch"
mkdir -p functions/hid.$C_N
echo 0 > functions/hid.$C_N/protocol
echo 0 > functions/hid.$C_N/subclass
echo 5 > functions/hid.$C_N/report_length
if [ -f "$SRC/touch.desc" ]; then
    cat "$SRC/touch.desc" > functions/hid.$C_N/report_desc
else
    echo "Warning: touch.desc not found at $SRC/touch.desc"
fi

# Create configuration
D=1
mkdir -p configs/c.$D/strings/0x409
echo "Config $D: HID Gadget" > configs/c.$D/strings/0x409/configuration 
echo 250 > configs/c.$D/MaxPower 

# Link functions to configuration (suppress errors if already linked)
ln -s functions/hid.$A_N configs/c.$D/ 2>/dev/null
ln -s functions/hid.$B_N configs/c.$D/ 2>/dev/null
ln -s functions/hid.$C_N configs/c.$D/ 2>/dev/null

# Find UDC (USB Device Controller)
UDC_NAME=$(ls /sys/class/udc | head -n 1)

if [ -z "$UDC_NAME" ]; then
    echo "Error: No USB Device Controller (UDC) found."
    echo "Make sure you have added 'dtoverlay=dwc2' to your config.txt and rebooted."
    exit 1
fi

# Bind gadget to UDC
echo "Binding gadget to $UDC_NAME..."
echo "$UDC_NAME" > UDC

# Wait for devices to be created
sleep 1

# Change permissions for HID devices
if ls /dev/hidg* >/dev/null 2>&1; then
    chmod 777 /dev/hidg*
    echo "HID gadget successfully set up. Devices: $(ls /dev/hidg*)"
else
    echo "Error: HID devices /dev/hidg* were not created."
    echo "Check dmesg for errors."
    exit 1
fi
