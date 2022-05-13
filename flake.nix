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

      mkImages = { imageName, countries, sites }:
        (map ({ hardware, countryCode }: {
          name = "${imageName}-${hardware}-${countryCode}";
          value = qwifiSystem { inherit hardware countryCode imageName sites; };
        }) (pkgs.lib.cartesianProductOfSets {
          hardware = [ "raspberryPi3" "raspberryPi4" ];
          countryCode = countries;
        }));
    in rec {
      nixosConfigurations = builtins.listToAttrs (builtins.concatLists [
        # Ghana.
        (mkImages {
          imageName = "ghana";
          countries = [ "NL" "DE" "GH" ];
          sites.ghana = inputs.ghana;
        })
      ]);

      images = builtins.mapAttrs (_: cfg:
        (cfg.extendModules {
          modules = [ ./sd-image.nix ];
        }).config.system.build.sdImage) nixosConfigurations;

      allImages = pkgs.buildEnv {
        name = "images";
        paths = map (p: "${p}/sd-image") (pkgs.lib.attrValues images);
      };
    };
}
