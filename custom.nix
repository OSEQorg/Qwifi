{ pkgs, lib, config, ... }: {

  options.qwifi = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "qwifi";
      description = "hostname without domain";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "lan";
    };

    hardware = lib.mkOption {
      type = lib.types.enum [ "raspberryPi3" "raspberryPi4" ];
      description = ''
        Hardware type
      '';
    };

    ssid = lib.mkOption {
      type = lib.types.str;
      default = "qwifi";
    };

    countryCode = lib.mkOption {
      type = lib.types.str;
      description = ''
        Country code (ISO/IEC 3166-1). Used to set regulatory domain for WiFi.

        See: services.hostapd.countryCode
      '';
    };

    sites = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Static sites to host on the Qwifi.

        The key of the attrs is the hostname (without the domain).
        The value is a path to the static site content.
      '';
    };
  };
}
