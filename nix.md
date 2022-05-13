## Inspired by

https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/
https://github.com/matthewbauer/nixiosk

## On NixOS

### Building image

```bash
nix build .#images.ghana-raspberryPi3-nl -L
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

## Update

```
nix flake update
```

## Creating your own image

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
        ++ (map ({ hardware, countryCode }: {
          name = "foo-${hardware}-${countryCode}";
          value = qwifiSystem {
            inherit hardware;
            inherit countryCode;
            sites.foo = inputs.foo;  # <-- domain "foo.lan" refers to static content in input.
          };
        }) (pkgs.lib.cartesianProductOfSets {
          hardware = [ "raspberryPi3" "raspberryPi4" ];
          countryCode = [ "NL" "DE" "GH" ];  # <-- change this to countries Pi will be in.
        }))
      ])
```

Build an image:

```bash
nix build .#images.foo-raspberryPi3-NL
```
