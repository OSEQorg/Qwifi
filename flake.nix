{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ghana = {
      url = "github:OSEQorg/Asanta-Twi-Audio-App/main";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      qwifiSystem = params:
        import ./default.nix {
          system = "aarch64-linux";
          inherit inputs;
          inherit (inputs) nixpkgs self;
          modules = [
            { config._module.args = { inherit (self) modulesPath; }; }
            { nix.registry = { nixpkgs = { flake = nixpkgs; }; }; }
            { qwifi = params; }
          ];
        };

      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in rec {
      nixosConfigurations = builtins.listToAttrs (builtins.concatLists [
        # Ghana.
        (map ({ hardware, countryCode }: {
          name = "ghana-${hardware}-${pkgs.lib.toLower countryCode}";
          value = qwifiSystem {
            inherit hardware;
            inherit countryCode;
            sites.ghana = inputs.ghana;
          };
        }) (pkgs.lib.cartesianProductOfSets {
          hardware = [ "raspberryPi3" "raspberryPi4" ];
          countryCode = [ "NL" "DE" "GH" ];
        }))
      ]);

      images = builtins.mapAttrs (_: cfg:
        (cfg.extendModules {
          modules = [ ./sd-image.nix ];
        }).config.system.build.sdImage) nixosConfigurations;
    };
}
