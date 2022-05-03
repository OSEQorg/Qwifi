## Inspired by

https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/
https://github.com/matthewbauer/nixiosk

## Building image

```bash
nix build .#images.qwifi -L
sudo dd if=result/sd-image/qwifi-... of=/dev/sdX status=progress
```

- Boot up a raspberry pi with the flashed image (either via USB or SD-card).
- Have the Pi connected to your local network via the Ethernet port.
- SSH to the Pi with `ssh qwifi@qwifi` the initial password is `qwifi`.
- Change the default password: `passwd`

## Live updating

```bash
export NIX_SSHOPTS="-t" nixos-rebuild --flake '.#qwifi' switch --target-host qwifi --build-host localhost --use-remote-sudo -L
```
