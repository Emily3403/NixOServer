{ config, lib, pkgs, ... }: { imports = [ ./boot.nix ./fileSystems.nix ./host.nix ./services ]; }
