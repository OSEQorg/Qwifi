{ pkgs, lib, config, ... }: {
  config = lib.mkIf
    (builtins.elem config.qwifi.hardware [ "raspberryPi3" "raspberryPi4" ]) {
      boot.tmpOnTmpfs = true;
      boot.kernelPackages = {
        raspberryPi3 = pkgs.linuxPackages_rpi3;
        raspberryPi4 = pkgs.linuxPackages_rpi4;
      }.${config.qwifi.hardware} or (throw
        "Unknown raspberry pi system (${config.qwifi.hardware})");

      boot.initrd.includeDefaultModules = false;
      boot.kernelModules = [ "vc4" ];
      boot.initrd.availableKernelModules = lib.mkForce [
        "usbhid"
        "usb_storage"
        "vc4"
        "bcm2835_dma"
        "i2c_bcm2835"
      ];

      boot.loader.grub.enable = false;
      boot.loader.raspberryPi = {
        enable = true;
        version = {
          raspberryPi3 = 3;
          raspberryPi4 = 4;
        }.${config.qwifi.hardware} or (throw
          "No known raspberrypi version for ${config.qwifi.hardware}.");

        uboot.enable = true;
        uboot.configurationLimit = 5;
      };

      fileSystems = {
        "/boot/firmware" = {
          device = "/dev/disk/by-label/FIRMWARE";
          fsType = "vfat";
          options = [ "nofail" "noauto" ];
        };
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
          autoResize = true;
        };
      };

      hardware.firmware =
        [ pkgs.wireless-regdb pkgs.raspberrypiWirelessFirmware ];
    };
}
