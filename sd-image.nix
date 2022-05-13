{ pkgs, config, lib, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];

  boot.loader.raspberryPi.enable = lib.mkForce false;

  sdImage = {
    # Compressing on emulated aarch64-linux is slow.
    compressImage = false;
    imageBaseName = "${config.qwifi.imageName}-${config.qwifi.hardware}-${config.qwifi.countryCode}";
  };

  boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];
}
