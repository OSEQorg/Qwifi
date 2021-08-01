# Qwifi

# Requirements

- Raspberry Pi 3B or newer

# Flash the image

on a USB stick or SD card.

# Mount the filesystem

Navigate to the /var/www/html folder on the mounted filesystem. Create a
directory for each website you want to have hosted on the Qwifi. The name of the
directory also determines the local domainname that can be used to access the
website. For example: a directory named `audiopedia` will be available to users
connected to the Qwifi via `http://audiopedia.lan`.

## First boot

Put the USB stick or SD card in a Raspberry Pi. Connect a Ethernet cable to the
Pi and your local network. Ethernet is only required for the first boot, after
that you can remove it. You can keep it and share the internet via the Qwifi,
but be very careful about this as there is no encryption and anyone can connect!

Connect power to the Pi and wait a minute or so for it to boot.

Connect via SSH to the Pi the password is default: `raspberry`.

```bash
ssh pi@qwifi
```

## Resize partition

The first thing you should do is to resize the filesystem to use the entire USB stick or SD card:

```bash
sudo raspi-config nonint do_expand_rootfs
```

## Read only

This step is optional. Making the filesystem read only will greatly enhance the
life of your USB stick or SD card.

```bash
sudo raspi-config nonint enable_bootro
sudo raspi-config nonint enable_overlayfs
sudo reboot
```

If you want to make changes to the filesystem, you can disable read only mode by:

```bash
sudo raspi-config nonint disable_overlayfs
sudo raspi-config nonint disable_bootro
```
