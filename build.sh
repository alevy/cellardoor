#!/bin/sh
echo $(nix-build -A sdImage -I nixpkgs="https://github.com/NixOS/nixpkgs/archive/release-20.09.tar.gz" --no-out-link $@)/sd-image/raspi-cellardoor.img
