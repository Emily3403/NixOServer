# configuration in this file is shared by all hosts

{ pkgs, pkgs-unstable, inputs, ... }:
let inherit (inputs) self;
in {

  # Safety mechanism: refuse to build unless everything is tracked by git
  system.configurationRevision = if (self ? rev) then
    self.rev
  else
    throw "refusing to build: git tree is dirty";

  # NixOS Setup
  system.stateVersion = "23.05";
  boot.zfs.forceImportRoot = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;

  # TODO: Enable automatic snapshots
  services.zfs = {
    autoSnapshot = {
      enable = false;
      flags = "-k -p --utc";
      monthly = 48;
    };
  };

  # Programs

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


  # TODO: Migrate this away?
  users.users = {
    root = {
      initialHashedPassword = "$6$HHFKYaj3WY/sPMDi$3CeWQX0XVZ1MvVEavfFB1GHnvrtL7oEar1MrT9pl4H0I1kNW6da5dN/iZh6nKoSMDfOb5aDryeYpWGicmgCYk/";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDzUPvWYTbiCPKlH08an2AnJINJwzttQRLklVkW4NxcYTlYSb/n5rEHbE+FJIo1XPtSMb/T8mLJ2EfuVVxnbfU72YbAw60iRVvv1B6MmL7FaVPO44VZKrV6UleG3peCtQglThD0TgRAbNnCMa9GM3aGZBJvplMTlgEVnI+lUTQ2N/ES4/8kkA6/vmm1G+NYk1HQorJPP9+kS0O4bCtbfr+qif82qBoXwkGYpuvspOaYYN1GEelmO13QozVlRhZKONrhnDbg8JDhGnocFZ1k8L5zqUmLZWpyE0pWlUFrxuoqPAK5DzzCh02xxSfRSi3SgQm1hUzYDl2/vPg4PGed2qUJUUhIX42YYlD6r4fndZV3b4I0O86Dn4bExCzdD3MpUiingHJ19cjxfotUUJ66+srV46Bxr5bwrhM3mKleIzZVS3XlLCs3usTNMc7g8tBUkZ9LspRC5wgxf+LqjDa8BVottpEUqaKPLO81R9/3DDS+iyLh92XNaArgw1PF0uLPCeU= emily@UwU" ];

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
    sysstat
    pv
    du-dust

  ];


}
