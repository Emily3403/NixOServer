{ pkgs, config, lib, inputs, ... }: {
  users.mutableUsers = false;

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;
}
