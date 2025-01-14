{ config, lib, pkgs, ... }: {
  imports = [
    ../root.nix
    ../emily.nix

    ../backup.nix
    ../emily-backup.nix
    ../data-backup.nix

    ../hscout.nix
  ];
}
