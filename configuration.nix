{ config, pkgs, lib, modulesPath, ... }:

let
  cfg = config.qwifi;
  fqdn = hostName: "${hostName}.${cfg.domain}";

  network = "192.168.4.0";
  ip = "192.168.4.1";
  prefixLength = 24;
  dhcpStart = "192.168.4.10";
  dhcpEnd = "192.168.4.254";
in {
  imports = [ ./custom.nix ./qwifi.nix ./raspberrypi.nix ];

  networking = {
    hostName = cfg.hostName;
    wireless.enable = false; # No wpa_supplicant please.
  };

  users.mutableUsers = true; # Allow passwd change.

  users.users.qwifi = {
    uid = 1000;
    isNormalUser = true;
    initialPassword = "qwifi";
    extraGroups = [ "wheel" ];
  };

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.settings = {
    sandbox = true;
    trusted-users = [ "root" "@wheel" ];
    allowed-users = [ "root" "@wheel" ];
  };

  environment.systemPackages = [ pkgs.git ];

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 53 67 ]; # DNS & DHCP.
    allowedTCPPorts = [ 22 80 ]; # SSH and HTTP.
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s ${network}/${toString prefixLength} -o eth0 -j MASQUERADE
    '';
  };

  networking.interfaces."wlan0".ipv4.addresses = [{
    address = ip;
    inherit prefixLength;
  }];

  # Increase entropy for hostapd.
  services.haveged.enable = true;

  services.hostapd = {
    enable = true;
    interface = "wlan0";
    inherit (cfg) countryCode ssid;
    wpa = false;
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "1.1.1.1" ];
    extraConfig = ''
      interface=wlan0
      bind-interfaces
      dhcp-range=${dhcpStart},${dhcpEnd},24h
      dhcp-option=3,${ip} # gateway
      dhcp-option=6,${ip} # DNS
      domain=${cfg.domain}
      address=/${fqdn cfg.hostName}/${ip}
      ${lib.concatStringsSep "\n"
      (lib.mapAttrsToList (hostName: _: "address=/${fqdn hostName}/${ip}")
        cfg.sites)}
    '';
  };

  # Enable IP forwarding.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Create a virtualHost for each site in cfg.sites. Also configure a default
  # virtual host that lists all sites on the device.
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = (lib.flip lib.mapAttrs' cfg.sites
      (name: root: lib.nameValuePair (fqdn name) { inherit root; })) // {
        # TODO: render a nice mobile friendly listing?
        ${fqdn cfg.hostName} = {
          default = true;
          root = pkgs.linkFarm "root" (lib.flip lib.mapAttrsToList cfg.sites
            (name: root: {
              inherit name;
              path = root;
            }));
          locations."/".extraConfig = ''
            autoindex on;
          '';
        };
      };
  };

  # Preserve space.
  documentation.nixos.enable = false;
  powerManagement.enable = false;
  programs.command-not-found.enable = false;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
}
