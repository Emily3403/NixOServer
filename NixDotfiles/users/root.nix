{ pkgs, config, lib, inputs, ... }: {
  security.sudo.enable = true;

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };

  };

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
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];

      shell = pkgs.fish;
    };
  };

  environment.systemPackages = with pkgs; [
    sudo
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
    sysstat
    pv
    du-dust
    ripgrep
  ];
}