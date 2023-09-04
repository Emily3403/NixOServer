# Unfortunately, Gollum does not seam to have all the features we desire. Because of that, we will not be using it.
# This file shall stay for now to demonstrate why it woudn't work.
{ pkgs, config, lib, ...}: {
  services.gollum = {
    enable = true;
    mathjax = true;

    stateDir = "/data/gollum";
  };
}