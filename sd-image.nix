{ pkgs, lib, modulesPath, config, ... }:
 
{
  imports = [
    "${modulesPath}/installer/cd-dvd/sd-image.nix"
  ];

  sdImage.compressImage = false;

  sdImage = {
    imageName = "raspi-cellardoor.img";
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        kernel=u-boot-rpi3.bin

        # Boot in 64-bit mode.
        arm_control=0x200

        # U-Boot used to need this to work, regardless of whether UART is actually used or not.
        # TODO: check when/if this can be removed.
        enable_uart=1

        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1
      '';
      in ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
        cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin
        cp ${configTxt} firmware/config.txt
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
