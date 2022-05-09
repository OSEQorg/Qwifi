## Inspired by

https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/
https://github.com/matthewbauer/nixiosk

## On NixOS

### Building image

```bash
nix build .#images.qwifi -L
sudo dd if=result/sd-image/qwifi-... of=/dev/sdX status=progress
```

- Boot up a raspberry pi with the flashed image (either via USB or SD-card).
- Have the Pi connected to your local network via the Ethernet port.
- SSH to the Pi with `ssh qwifi@qwifi` the initial password is `qwifi`.
- Change the default password: `passwd`

### Live updating

```bash
export NIX_SSHOPTS="-t" nixos-rebuild --flake '.#qwifi' switch --target-host qwifi --build-host localhost --use-remote-sudo -L
```


## On Ubuntu

### Install prerequisites

Install qemu-user for aarch64 emulation:

```bash
sudo add-apt-repository universe
sudo apt update
sudo apt install -y qemu-user
```

Install Nix:

```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Configure Nix:

```
cat <<EOF | sudo tee -a /etc/nix/nix.conf
extra-experimental-features = nix-command flakes
extra-platforms = aarch64-linux
sandbox = false
EOF
```