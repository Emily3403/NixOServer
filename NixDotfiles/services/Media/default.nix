{ config, lib, pkgs, ... }: { imports = [ ./Jellyfin.nix ./Jellyseerr.nix ./Radarr.nix ./Transmission.nix ]; }
