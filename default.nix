{ nixpkgs ? <nixpkgs>, self ? null, system, modules ? [ ], ... }:

let pkgs = import nixpkgs { inherit system; };
in import (pkgs.path + /nixos/lib/eval-config.nix) ({
  inherit system;
  modules = modules ++ [
    ./configuration.nix
    {
      config._module.args = {
        modulesPath =
          if isNull self then "${nixpkgs}/nixos/modules" else self.modulesPath;
      };
    }
    {
      nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
    }
  ] ++ (pkgs.lib.optional ((isNull self) == false) {
    system.nixos.versionSuffix = ".${
        pkgs.lib.substring 0 8
        (self.lastModifiedDate or self.lastModified or "19700101")
      }.${self.shortRev or "dirty"}";
    system.nixos.revision = pkgs.lib.mkIf (self ? rev) self.rev;
  });

})
