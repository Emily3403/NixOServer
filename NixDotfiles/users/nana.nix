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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTJ0U/Gcc+PPAA1lAt1vzhLp2KCQNz828LARWZjDTCJaRzyLzF+eG0c6d9XZhBiTbvNRED8huizH73JubRs3ja4fEomwlxn0DY3uxzYoCA0lmTEWya2rXfgvpOxKbN/fCREkDmQTOHCoWcatFPFGLGTAgVlfUUvBLOVSrt+Knn8YnnKBKctQYAQV2nDc+bZ4Vc5PGpkgaXaGBjWGT7I4B6UwkDAfVQf47QmKdBdvoI1H41+KiF6h7QZqdMnCJlDNs5N3CS+GD3hQM4qeX2amJnLFc7mTwewHVjjOBIYHJjPj7BKzz/bzH9ZLl1HRAVJ+WZNMXbjW0X0VfY+ZzvLVWzzaxnpI5C3/Y+CiNaRt5D9GdkOpd1bx0Shh5oqJE4NOs1G3YRW3OTcAYsxKngl07bZa4bi5oMgukLA+UvonpL0DHoPhFMDG/vVF97X41Z1YUXzuB6u/UmBuOGO53BKD+2UrwkSz9wQNpz/wVfG+2dxi/AhYU5o0VYbOY41r2EJfpGgTD9gn7n9fZj5S+Jm6e5Yne4A//Dl6n+LGnk4Ujgq8Dlp2Qkhv2MAxpGWJ/5/6cu89eFK3BCozElLco727uXGwbJEGgMpIqWcfPW4Dvyc6UUXHDS/+81ZrYZVMZClQa53ZCmJl8ppLxBHCTTrRFJypPL/anhKAIxqoA1coaZ+w=="
    ];

  };
}