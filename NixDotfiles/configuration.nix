# configuration in this file is shared by all hosts

{ pkgs, pkgs-unstable, inputs, lib, config, ... }:
let
  inherit (inputs) self;
in
{

  # Safety mechanism: refuse to build unless everything is tracked by git
  system.configurationRevision =
    if (self ? rev) then
      self.rev
    else
      throw "refusing to build: git tree is dirty";

  # NixOS Setup  TODO: Migrate this to system.nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  environment.defaultPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
  ];

}
