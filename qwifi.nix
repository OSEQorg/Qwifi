{ pkgs, ... }: {
  qwifi = {
    hostName = "qwifi";
    hardware = "raspberryPi3";
    ssid = "qwifi";
    countryCode = "NL";
    sites = {
      ghana = pkgs.runCommand "ghana" {} ''
        ${pkgs.unzip}/bin/unzip ${./Ghana.zip} "Ghana/*" -d .
        find . -name .DS_Store -o -name __MACOSX -delete
        mkdir $out
        mv Ghana/* $out/
      '';
    };
  };
}
