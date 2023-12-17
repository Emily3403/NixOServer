{ pkgs, config, lib, ... }: {
  users.users.emily = {
    isNormalUser = true;
    home = "/home/emily";
    description = "Emily Seebeck";

    shell = pkgs.fish;
    createHome = true;
    uid = 1042;
    extraGroups = [ "wheel" ];


    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDzUPvWYTbiCPKlH08an2AnJINJwzttQRLklVkW4NxcYTlYSb/n5rEHbE+FJIo1XPtSMb/T8mLJ2EfuVVxnbfU72YbAw60iRVvv1B6MmL7FaVPO44VZKrV6UleG3peCtQglThD0TgRAbNnCMa9GM3aGZBJvplMTlgEVnI+lUTQ2N/ES4/8kkA6/vmm1G+NYk1HQorJPP9+kS0O4bCtbfr+qif82qBoXwkGYpuvspOaYYN1GEelmO13QozVlRhZKONrhnDbg8JDhGnocFZ1k8L5zqUmLZWpyE0pWlUFrxuoqPAK5DzzCh02xxSfRSi3SgQm1hUzYDl2/vPg4PGed2qUJUUhIX42YYlD6r4fndZV3b4I0O86Dn4bExCzdD3MpUiingHJ19cjxfotUUJ66+srV46Bxr5bwrhM3mKleIzZVS3XlLCs3usTNMc7g8tBUkZ9LspRC5wgxf+LqjDa8BVottpEUqaKPLO81R9/3DDS+iyLh92XNaArgw1PF0uLPCeU= emily@UwU"
    ];

  };
}