# Qwifi

## About

Technology is revolutionizing the world by providing tools for entrepreneurship,
access to education, as well as life-enhancing information. Yet women in
developing countries increasingly have limited access to technology, resulting
in a digital gender divide. Women face a variety of barriers to mobile access,
with data costs and illiteracy topping the list. Even if a woman has a device,
she may not be able to use it to its full potential.

Qwifi can solve this problem. It’s a simple, accessible and cheap technology
that can provide free audiovisual content to marginalized populations. Qwifi can
be used in any scenario where information and knowledge transfer is required and
where parts of the target audience have access to smartphones. Qwifi serves the
content by creating a local Wifi network, without the need of any internet
connection and independently from the electric grid.

## What this repository provides

This repository provides a framework to build Qwifi images (an image in this
context is a file to write to a flash drive). These images contain one or more
static websites together with a fully configured Linux distribution that will
host an access point and the static websites.

## Requirements

- Raspberry Pi 3B or 4
- USB stick of 4GB or larger (USB3.0 stick is recommended)

### To build new images

- x86_64 system with Linux (Ubuntu or NixOS are supported).

## Images

### Naming

Images are named: `$name-$hardware-$countryCode`. The variables are:

| Variable       | Description                                                                          | Values                         |
|----------------|--------------------------------------------------------------------------------------|--------------------------------|
| `$name`        | Name of the image, this usually refers to the content                                | `ghana`                        |
| `$hardware`    | Hardware to run image on                                                             | `raspberryPi3`, `raspberryPi4` |
| `$countryCode` | Country code for wireless regulatory domain (allowed frequencies differ per country) | `NL`, `DE`, `GH`               |

Images for the following static contents are available:

| Content | Description                                     |
|---------|-------------------------------------------------|
| `ghana` | https://github.com/OSEQorg/Asanta-Twi-Audio-App |

## Usage

### Flashing an image

- Insert USB stick or SD card into your computer
- Install [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
- Run the application
- Choose OS > Use custom > Select the downloaded file (`*.img.gz`) file
- Choose storage > Select the USB stick or SD card
- Write

### First boot

- Put the USB stick or SD card in a Raspberry Pi.
- Connect a Ethernet cable to the Pi and your local network. Ethernet is only
  required for the first boot, after that you can remove it. You can keep it and
  share the internet via the Qwifi. **Be very careful about this as there is
  no encryption and anyone can connect!**
- Connect power to the Pi and wait a minute or so for it to boot.
- Connect via SSH to the Pi the password is default: `qwifi`:
  ```bash
  ssh qwifi@qwifi
  ```
- Change the default password:
  ```bash
  passwd
  ```

### Testing it

- The Pi broadcasts a WiFi network named `qwifi`, you can connect to this without entering a password.
- Navigate to `http://qwifi.lan`. You should see a list of all sites on the device.
- You can also navigate directly to the content, for example: `http://ghana.lan`
