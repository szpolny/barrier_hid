# Barrier HID ( Synergy )

This is a fork of the open source core component of Synergy, a keyboard
and mouse sharing tool.
For compilation and configuration, check
[the main repo](https://github.com/debauchee/barrier).

In certain cases - for example where installing the client on the system
is not possible, this project helps to remediate that.

It does that by using raspberry pi as a proxy ( hid device )
that emulates usb keyboard and mouse ( and touch ). 

## Required hardware

Raspberry Pi Zero W connected to same network as Barrier server.

**Note: Currently only tested on Raspberry Pi Zero 2 W with Raspberry Pi OS Lite.**

## Building the solution

To build the solution, you need to install the dependencies and run the build script. This is best done on a Raspberry Pi Zero W or Zero 2 W running Raspberry Pi OS (Tested using lite).

```bash
git clone https://github.com/szpolny/barrier_hid.git
cd barrier_hid
chmod +x *.sh
./build.sh
```

## Hardware setup 

Raspberry Pi Zero W needs to be configured as a USB OTG Gadget.

1. **Enable OTG Mode**: Run the following script and **reboot** your Raspberry Pi.
   ```bash
   sudo ./otg_mode_setup.sh
   sudo reboot
   ```
2. **Enable HID Gadget**: Run the HID setup script. **This must be done after every boot** (you can add it to `/etc/rc.local` or create a systemd service).
   ```bash
   sudo ./hid_setup.sh
   ```

## Usage

To start the client and connect to your Barrier server, use the following command:

```bash
./build/bin/barrierc --client --name <client_name> -f --hid /dev/hidg0 /dev/hidg1 /dev/hidg2 <width> <height> <server_ip>
```
*   `<client_name>`: The name of this client as configured on your Barrier server.
*   `<width> <height>`: The resolution of the monitor connected to the server (e.g., `1920 1080`).
*   `<server_ip>`: The IP address of your Barrier server.

> **Note**: For best performance on Pi Zero, it is recommended to disable SSL on the Barrier server.

## Limitations/Issues

- No clipboard - as Pi Zero is proxy clipboard functionality would require supporting app or mass storage to make it work


