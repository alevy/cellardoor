{ ... }:

let env = (import <nixpkgs/nixos/lib/eval-config.nix> {
  system = "aarch64-linux";
  modules = [
    ./sd-image.nix
    ./configuration.nix
  ];
});
in {
  toplevel = env.config.system.build.toplevel;
  sdImage = env.config.system.build.sdImage;
}
