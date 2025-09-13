{ config, lib, pkgs, ... }: { imports = [ ./Radarr.nix ./NZBHydra.nix ./Sonarr.nix ./Prowlarr.nix ./Flaresolverr.nix ]; }
