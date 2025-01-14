{ config, lib, pkgs, ... }: {
  imports = [
    ../root.nix
    ../emily.nix
    ../nana.nix

    ../backup.nix
  ];
}
