{ pkgs, inputs, config, lib, ... }: {
  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;

  # nixpkgs
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  };

  # NixOS Setup
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Podman
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings = { dns_enabled = false; };
    dockerCompat = true;
  };

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"  # Default
    "en_IE.UTF-8/UTF-8"  # Sensible currencies and date formats
    "en_GB.UTF-8/UTF-8"  # For Others
  ];

  systemd.tmpfiles.rules = [
    "d /data 0750 root nginx"
  ];

  # User setup
  users = {
    mutableUsers = false;

    users = {
      postgres = {
        uid = config.ids.uids.postgres;
        group = "postgres";
      };

      mysql = {
        uid = config.ids.uids.mysql;
        group = "mysql";
      };
    };

    groups.postgres.members = [ "postgres" ];
    groups.mysql.members = [ "mysql" ];
  };
}
