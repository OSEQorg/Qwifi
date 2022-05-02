## Inspired by

https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/
https://github.com/matthewbauer/nixiosk

## Building image

```bash
nix build .#images.qwifi -L
sudo dd if=result/sd-image/qwifi-... of=/dev/sdX status=progress
```

## Live updating

```bash
export NIX_SSHOPTS="-t" nixos-rebuild --flake '.#qwifi' switch --target-host qwifi --build-host localhost --use-remote-sudo -L
```
