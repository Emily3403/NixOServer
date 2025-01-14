{ config, lib, pkgs, ... }: { imports = [
  ./Transmission.nix
  ./Jellyfin.nix
  ./Jellyseerr.nix
  ./FileBrowser.nix
  ./Arr
]; }
