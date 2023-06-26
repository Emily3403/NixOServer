# Currently, there is too little information and tutorials on the internet to use Traefik with NixOS.
# In the future, this might be an avenue that is worth exploring. For now, however, I don't feel like it.
{ pkgs, config, lib, ...}: {
  services.traefik = {
    enable = true;

    dataDir = "/data/traefik";
  };
}