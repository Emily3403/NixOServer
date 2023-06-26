let
  getThemePackage = pkgs: { name, url, rev, path }: pkgs.stdenv.mkDerivation rec {
    inherit name;

    src = fetchGit {
      inherit url rev;
    };

    installPhase = ''
      mkdir -p $out
      cp -r $src/${path}/* $out/
    '';
  };

in

{ pkgs, config, lib, ...}: {
  services.keycloak = {
    enable = true;

    settings = {
      hostname = "keycloak.${config.domainName}";
      hostname-admin = "keycloak-admin.${config.domainName}";

      hostname-strict-backchannel = true;
      proxy = "edge";

      http-port = 1234;
      https-port = 10001;
    };

    database = {
      passwordFile = config.age.secrets.KeyCloakDatabasePassword.path;
    };

    initialAdminPassword = "UwU";  # change on first login

    themes =  {
      keywind = (getThemePackage pkgs) {
        name = "keywind";
        url = "https://github.com/lukin/keywind";
        rev = "f7d5b2d753524802481e49e0e967af39a5088de0";
        path = "theme/keywind";
      };
    };
  };

  services.nginx.virtualHosts = {
    "keycloak.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        # According to https://www.keycloak.org/server/reverseproxy#_exposed_path_recommendations
        "~* ^/(admin|welcome|metrics|health)(/.*)?$".return = "403";
        "/".proxyPass = "http://localhost:1234";
      };
    };

    "keycloak-admin.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:1234/";

      extraConfig = ''
        satisfy any;

        allow 192.168.16.0/24;
        allow 192.168.200.0/24;
        allow 192.168.201.0/24;
        allow 192.168.220.0/24;

        deny all;
      '';
    };
  };
}