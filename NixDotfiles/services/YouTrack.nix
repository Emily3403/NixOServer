{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "asktheadmins.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://192.168.7.105:8080/";
    };
  };

  containers.youtrack =
  let
    domainName = config.domainName;
  in
   {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.105";

    bindMounts = {
      "/var/lib/youtrack/" = {
        hostPath = "/data/YouTrack/youtrack";
        isReadOnly = false;
      };
    };

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";
      documentation.man.generateCaches = false;
      networking.firewall.allowedTCPPorts = [ 8080 ];
      nixpkgs.config.allowUnfree = true;

      users.users = {
        youtrack = {
          isSystemUser = true;
          uid = 5005;
          group = "youtrack";
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
      users.users.root.shell = pkgs.fish;

      services.youtrack = {
        enable = true;

        address = "0.0.0.0";

        package = pkgs.youtrack;

      };



  environment.systemPackages = with pkgs; [
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


    };

  };


  users.users = {
    youtrack = {
      isSystemUser = true;
      uid = 5005;
      group = "youtrack";
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/YouTrack/youtrack/ 0755 youtrack"
  ];

}