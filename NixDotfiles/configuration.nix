{ zfs-root, inputs, pkgs, config, lib, ... }: {
  # load module config to here
  inherit zfs-root;

  # Let 'nixos-version --json' know about the Git revision of this flake.
  system.configurationRevision = if (inputs.self ? rev) then
    inputs.self.rev
  else
    throw "refuse to build: git tree is dirty";

  system.stateVersion = "23.05";
  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  # TODO: Add symlinks for wiki, acme and other /var/lib services with their respective groups
  #  Also: Setup database correctly from the get-go for the next install

  # "it is highly recommended to disable this option, as it bypasses some of the safeguards ZFS uses to protect your ZFS pools."
  boot.zfs.forceImportRoot = lib.mkForce true;

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;

   # Programs
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    fish.enable = true;
    git.enable = true;
  };

  security = {
    sudo.enable = lib.mkDefault true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # TODO: Migrate this away
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

  users.groups = {
    postgres.members = [ "postgres" ];
    hedgedoc.members = [ "hedgedoc" ];
    vaultwarden.members = [ "vaultwarden" ];
    mail.members = [ "mail" ];
    youtrack.members = [ "youtrack" ];
  };

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default

    jq
    wget
    zsh
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
    traceroute
    pv
    wireguard-tools

  ];

}
