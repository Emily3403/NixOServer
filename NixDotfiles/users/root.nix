{ pkgs, config, lib, inputs, ... }: {
  security.sudo.enable = true;

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ClientAliveInterval = 30;
      ClientAliveCountMax = 6;
    };
  };

  services.locate.enable = true;

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    fish.enable = true;
    git.enable = true;
  };

  users.users = {
    root = {
      initialHashedPassword = "!";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMooVZ98Wkne2js4jPgypBlPuxZGxJBu8QEhOdCkSTQj"
      ];

      shell = pkgs.fish;
    };
  };

  environment.systemPackages = with pkgs; [
    sudo
    jq
    wget
    fish
    zsh
    neofetch
    btop
    eza
    cowsay
    direnv
    htop
    rsync
    nmap
    inetutils
    util-linux
    parted
    python3
    python311Packages.pip
    groff
    openssl
    tcpdump
    traceroute
    dig
    sysstat
    pv
    du-dust
    ripgrep
    unzip
    unzrip
    intel-gpu-tools
#    wireguard-tools
    mediainfo
    termshark
    trippy
    smartmontools
  ];
}
