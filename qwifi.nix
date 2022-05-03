{ pkgs, inputs, ... }: {
  qwifi = {
    hostName = "qwifi";
    hardware = "raspberryPi3";
    ssid = "qwifi";
    countryCode = "NL";
    sites = {
      ghana = inputs.ghana;
    };
  };
}
