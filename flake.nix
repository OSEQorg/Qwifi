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
      qwifiSystem = args:
        import ./default.nix (args // {
          inherit inputs;
          inherit (inputs) nixpkgs self;
          modules = (args.modules or [ ]) ++ [
            { config._module.args = { inherit (self) modulesPath; }; }
            { nix.registry = { nixpkgs = { flake = nixpkgs; }; }; }
          ];
        });
    in {
      nixosConfigurations.qwifi = qwifiSystem { system = "aarch64-linux"; };

      images.qwifi = (qwifiSystem {
        system = "aarch64-linux";
        modules = [ ./sd-image.nix ];
      }).config.system.build.sdImage;
    };
}
