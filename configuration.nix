{ pkgs, lib, ... }:

with pkgs;
let
  cellardoorPy = pkgs.writeText "cellardoor.py" (builtins.readFile ./server.py);
  wireless = import ./wireless.nix;
  http_auth = import ./http_auth.nix;
in {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  boot.kernelPackages = pkgs.linuxPackages_rpi3;

  # The serial ports listed here are:
  # - ttyS0: for Tegra (Jetson TX1)
  # - ttyAMA0: for QEMU's -machine virt
  # Also increase the amount of CMA to ensure the virtual console on the RPi3 works.
  boot.kernelParams = ["cma=32M" "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"];

  boot.initrd.availableKernelModules = [
    # Allows early (earlier) modesetting for the Raspberry Pi
    "vc4" "bcm2835_dma" "i2c_bcm2835"
    # Allows early (earlier) modesetting for Allwinner SoCs
    "sun4i_drm" "sun8i_drm_hdmi" "sun8i_mixer"
  ];
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="US"
  '';

  environment.systemPackages = [
    vim
  ];

  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      default = true;
      basicAuth = http_auth;
      locations."/" = {
        proxyPass = "http://localhost:8000";
      };
    };
  };

  hardware.firmware = [ pkgs.wireless-regdb ];
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "garage-door";
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;
  networking.wireless = wireless;
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  users.users.root = {
    initialPassword = "raspberry";
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  systemd.services.cellardoor = {
    wantedBy = [ "multi-user.target" ]; 
    after = [ "network.target" ];
    description = "Cellar Door Service";
    path = [ pkgs.python3Packages.httpserver pkgs.libgpiod ];
    serviceConfig = {
      User = "root";
      ExecStart = "${pkgs.python3}/bin/python ${cellardoorPy} 8000";
      Restart = "on-failure";
      PrivateTmp = true;
    };
  };

  # Documentation just takes up space and a while to compile
  documentation.enable = false;
}
