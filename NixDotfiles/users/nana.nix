{ pkgs, config, lib, ... }: {
  programs.zsh.enable = true;

  users.users.nana = {
    isNormalUser = true;
    home = "/home/nana";
    description = "NANA";

    shell = pkgs.zsh;
    createHome = true;
    uid = 1043;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMooVZ98Wkne2js4jPgypBlPuxZGxJBu8QEhOdCkSTQj nana"
    ];

  };
}
