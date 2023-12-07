{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Headscale"; in
{
  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib;
        name = "headscale";
        containerIP = "192.168.7.110";
        containerPort = 8080;

        imports = [ ../users/services/headscale.nix ];
        additionalNginxLocationConfig.proxyWebsockets = true;

        bindMounts = {
          "/var/lib/headscale/" = { hostPath = "${DATA_DIR}/headscale"; isReadOnly = false; };
          "${config.age.secrets.Headscale_ClientSecret.path}" = { hostPath = config.age.secrets.Headscale_ClientSecret.path; };
        };

        cfg = {
          imports = [ (import ./Container-Config/Postgresql.nix { name = "headscale"; pkgs = pkgs; }) ];

          services.headscale = {
            enable = true;
            address = "0.0.0.0";

            settings = {
              server_url = "https://headscale.ruwusch.de";

              db_type = "postgres";
              db_host = "/run/postgresql";
              db_name = "headscale";
              db_user = "headscale";

              oidc = {
                client_id = "Headscale";
                client_secret_path = config.age.secrets.Headscale_ClientSecret.path;
                issuer = "https://keycloak.ruwusch.de/realms/Super-Realm";

                strip_email_domain = false;
              };
            };
          };
        };
      }
    )
  ];


  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/headscale/ 0750 headscale headscale"
  ];
}
