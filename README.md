# Qwifi

## About

Technology is revolutionizing the world by providing tools for entrepreneurship, access to education, as well as life-enhancing information. Yet women in developing countries increasingly have limited access to technology, resulting in a digital gender divide. Women face a variety of barriers to mobile access, with data costs and illiteracy topping the list. Even if a woman has a device, she may not be able to use it to its full potential. 

Qwifi can solve this problem. It’s a simple, accessible and cheap technology that can provide free audiovisual content to marginalized populations. Qwifi can be used in any scenario where information and knowledge transfer is required and where parts of the target audience have access to smartphones. Qwifi serves the content by creating a local Wifi network, without the need of any internet connection and independently from the electric grid. 

## Requirements

- Raspberry Pi 3B or newer
- USB stick or SD card of 4GB or larger (USB3.0 stick is recommended)

## Download the latest image

Download the latest image from: https://github.com/OSEQorg/qwifi/releases

## Flash the image

- Insert USB stick or SD card into your computer
- Install [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
- Run the application
- Choose OS > Use custom > Select the downloaded file (`qwifi_*.img.gz`) file
- Choose storage > Select the USB stick or SD card
- Write

## Add static sites

- Insert the medium and navigate to the `rootfs` partition in your file explorer.
- Navigate to the directory `var/www/html`.
- Create a directory for each site you want to host on the Qwifi. The name of
  the directory also determines the local domain name that can be used to access
  the website. For example: a directory named `audiopedia` will be available to
  users connected to the Qwifi via `http://audiopedia.lan`.
- Copy the static site files to the subdirectories.
- Cleanly eject the medium.

## First boot

- Put the USB stick or SD card in a Raspberry Pi.
- Connect a Ethernet cable to the Pi and your local network. Ethernet is only
  required for the first boot, after that you can remove it. You can keep it and
  share the internet via the Qwifi. **Be very careful about this as there is
  no encryption and anyone can connect!**
- Connect power to the Pi and wait a minute or so for it to boot.
- Connect via SSH to the Pi the password is default: `raspberry`:
  ```bash
  ssh pi@qwifi
  ```
- Change the default password:
  ```bash
  passwd
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

## Testing

- Connect to the WiFi network named: `qwifi` (no password)
- Navigate to `http://qwifi.lan`. You should see a list of all sites on the device.
- For each site that you copied to the device: navigate to `http://$site.lan`
  (replacing `$site` with the site's directory name).
