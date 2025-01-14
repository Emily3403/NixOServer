{ pkgs, config, lib, ... }: {
  services.nginx.virtualHosts."get.${config.host.networking.domainName}" = {
    forceSSL = true;
    enableACME = true;

    locations."/btop".return = "301 https://raw.githubusercontent.com/Emily3403/configAndDotfiles/refs/heads/main/roles/shell/tasks/dotfiles/btop/btop.conf";
    locations."/fish".return = "301 https://raw.githubusercontent.com/Emily3403/configAndDotfiles/refs/heads/main/roles/shell/tasks/dotfiles/fish/config.fish";
  };
}
