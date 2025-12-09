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
      initialHashedPassword = "rootHash_placeholder";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMooVZ98Wkne2js4jPgypBlPuxZGxJBu8QEhOdCkSTQj nana"
      ];

      shell = pkgs.fish;
    };
  };

  environment.systemPackages = with pkgs; [
    # Unix Tools
    util-linux
    inetutils
    ethtool
    sudo
    parted
    wget
    curl
    openssl
    jq
    rsync
    nmap
    unzip

    python3
    groff
    pv
    mediainfo

    # Rust tools
    unzrip
    eza
    dust
    ripgrep
    fd

    # system monitoring tools
    btop
    htop
    intel-gpu-tools
    smartmontools
    dmidecode
    pciutils
    tcpdump
    traceroute
    dig
    sysstat
    termshark
    trippy
    mtr
    iotop

    # Customization
    zsh
    fish
    neofetch
    cowsay
    direnv
  ];
}
