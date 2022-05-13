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

This repository provides a framework to build Qwifi images. An image in this
context is a file to write to a flash drive. These images contain one or more
static websites together with a fully configured Linux distribution that will
host an access point and the static websites.

## Requirements

- Raspberry Pi 3B or 4
- USB stick of 4GB or larger (USB3.0 stick is recommended)

### Additional requirements for building images

- 64bit x86 system (Intel or AMD)
- Linux operating system (Ubuntu or NixOS are supported).

## Images

### Naming

Images are named: `$name-$hardware-$countryCode-$version.img.gz`. The variables are:

| Variable       | Description                                                                          | Values                         |
|----------------|--------------------------------------------------------------------------------------|--------------------------------|
| `$name`        | Name of the image, this usually refers to the content                                | `ghana`                        |
| `$hardware`    | Hardware to run image on                                                             | `raspberryPi3`, `raspberryPi4` |
| `$countryCode` | Country code for wireless regulatory domain (allowed frequencies differ per country) | `NL`, `DE`, `GH`               |
| `$version`     | Version of NixOS used to build the image                                             | `22.05.20220513.aarch64-linux` |

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

## Build images

### Prerequisites

[Nix](https://nixos.org/) is used to build customized images. If you happen to
be on NixOS (an operating system build on Nix), you already have most of the
tools installed. Nix can also be installed on other (Linux) operating systems,
for Qwifi we only support Ubuntu.

Raspberry Pi's have a different hardware architecture (`aarch64-linux`) than the
machines we're building the images on (`x86_64-linux`). We could build the
images on a Pi, but awesome as Pi's are, they are not very fast. Another
approach would be to cross compile the entire image, but this too takes a long
time.

The approach we use Qwifi is to emulate parts of the build that need to be done
on `aarch64-linux` in a virtual machine. Using a clever trick called a `binfmt`
wrapper, Linux can be instructed to run a `aarch64-linux` binary in a Qemu
virtual machine.

#### NixOS

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

#### Ubuntu

Install qemu-user for aarch64 emulation:

```bash
sudo add-apt-repository universe
sudo apt update
sudo apt install -y qemu-user
```

Install Nix:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Configure Nix:

```bash
cat <<EOF | sudo tee -a /etc/nix/nix.conf
extra-experimental-features = nix-command flakes
extra-platforms = aarch64-linux
sandbox = false
EOF
```

### Building

```bash
nix build .#images.ghana-raspberryPi3-NL -L
```

This can take a while for the first build. It will fetch all required
dependencies from the NixOS cache and build the custom image based on the
configuration in `flake.nix`. The output will be in
`result/sd-image/ghana-raspberryPi3-NL-*.img`. The image can be flashed on an USB drive with Raspberry Pi Imager (see instructions above) or with `dd` as follows:

```bash
# DOUBLE check that /dev/sdX is the you want to flash!
sudo dd if=result/sd-image/ghana-raspberryPi3-NL-*.img of=/dev/sdX status=progress
```

### Live updating

When making changes to the Nix configuration of the image, it can be useful to
incrementally update a running system. Assuming the Pi is online and is
connected to the same LAN as your workstation. This command will live update:

```bash
export NIX_SSHOPTS="-t" nixos-rebuild --flake '.#ghana-raspberryPi3-NL' switch --target-host qwifi --build-host localhost --use-remote-sudo -L
```

### Adding new content

First make sure that the static content you want to host on the Qwifi is on
GitHub (or any other publicly accessible git host).

Open `flake.nix` and add the git repository to the `inputs`, for example:

```diff
 inputs = {
   nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
   # ...
+  foo = {
+    url = "github:org/foo/main";  # <-- format is: $owner/$repo/$branch
+    flake = false;
+  };
 };
```

Now you can reference this new `input` in the `nixosConfigurations` section, for example:

```nix
      nixosConfigurations = builtins.listToAttrs (builtins.concatLists [
        # ...
        ++ (mkImages {
          imageName = "foo";
          countries = [ "NL" "DE" "GH" ]; # <-- change this to countries Pi will be in.
          sites.foo = inputs.foo;   # <-- domain "foo.lan" refers to the static content in input.
          # sites.bar = inputs.bar; # <-- optionally you can add multiple sites.
        })
      ])
```

Build an image:

```bash
nix build .#images.foo-raspberryPi3-NL
```

## Credits

These sources greatly helped in building Qwifi on Nix:

- https://github.com/matthewbauer/nixiosk
- https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/
