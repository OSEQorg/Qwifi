## Inspired by



## On NixOS


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
