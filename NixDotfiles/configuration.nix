{ zfs-root, inputs, pkgs, lib, ... }: {
  # load module config to here
  inherit zfs-root;

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = if (inputs.self ? rev) then
    inputs.self.rev
  else
    throw "refuse to build: git tree is dirty";

  system.stateVersion = "22.11";

  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  # Enable GNOME
  # GNOME must be used with a normal user account.
  # However, by default, only root user is configured.
  # Create a normal user and set password.
  #
  # You need to enable all options in this attribute set.
  services.xserver = {
    enable = false;
    desktopManager.gnome.enable = false;
    displayManager.gdm.enable = false;
  };

   # Programs
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    fish = {
      enable = true;
    };
  };

  # Databases
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    dataDir = "/database/postgresql";
    settings.listen_addresses = lib.mkForce "*";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/database/mysql";

  };

  # Enable Sway window manager
  # Sway must be used with a normal user account.
  # However, by default, only root user is configured.
  # Create a normal user and set password.
  programs.sway.enable = false;

  users.users = {
    root = {
      initialHashedPassword = "rootHash_placeholder";
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];

      shell = pkgs.fish;
    };

    # "normalUser" is the user name,
    # change if needed.
    normalUser = {
      # Generate hashed password with "mkpasswd -m sha-512" command,
      # "!" disables login.
      # "mkpasswd" without "-m sha-512" will not work
      initialHashedPassword = "!";
      description = "Full Name";
      # Users in "wheel" group are allowed to use "doas" command
      # to obtain root permissions.
      extraGroups = [ "wheel" ];
      packages = builtins.attrValues {
        inherit (pkgs)
          mg # emacs-like editor
          jq # other programs
        ;
      };
      isNormalUser = true;

      shell = pkgs.fish;
    };
  };




  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
    # "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  services.openssh = {
    enable = lib.mkDefault true;
     settings = { PasswordAuthentication = lib.mkDefault false; };
  };

  networking.firewall = {
    allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
    allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
  };


  boot.zfs.forceImportRoot = lib.mkDefault false;

  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  programs.git.enable = true;

  # Secrets and security
  age.secrets = {
    KeyCloakDatabasePassword = {
      file = ./secrets/KeyCloak/DatabasePassword.age;
      owner = "mysql";
      group = "mysql";
    };

    KeyCloakAdminPassword = {
      file = ./secrets/KeyCloak/AdminPassword.age;
      owner = "mysql";
      group = "mysql";
    };

    NextcloudAdminPassword = {
      file = ./secrets/Nextcloud/AdminPassword.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    SSLCert = {
      file = ./secrets/ssl_cert.age;
      owner = "nginx";
      group = "nginx";
    };

    SSLKey = {
      file = ./secrets/ssl_key.age;
      owner = "nginx";
      group = "nginx";
    };

  };

  security = {
    sudo.enable = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default

    jq
    wget
    neofetch
    btop
    exa
    cowsay
    direnv
    htop
    rsync
    nmap
    inetutils
    python3
    groff
    openssl
    tcpdump

  ];

}
