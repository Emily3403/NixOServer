{ pkgs, config, lib, inputs, ... }: {
  system.stateVersion = "23.05";

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;
}
