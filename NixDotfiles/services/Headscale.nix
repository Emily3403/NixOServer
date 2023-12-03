{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Headscale"; in
{
  imports = [
    ../users/services/headscale.nix
  (
      import ./Container-Config/Nix-Container.nix {
        inherit config;
        name = "headscale";
        subdomain = "headscale";
        containerIP = "192.168.7.110";
        containerPort = 8080;
        proxyWebsockets = true;

        bindMounts = {
          "/var/lib/headscale/" = { hostPath = "${DATA_DIR}/headscale"; isReadOnly = false; };
          "${config.age.secrets.Headscale_ClientSecret.path}" = { hostPath = config.age.secrets.Headscale_ClientSecret.path; };
        };

        cfg = {
          imports = [
            ../users/services/headscale.nix
            (import ./Container-Config/Postgresql.nix { dbName = "headscale"; dbUser = "headscale"; pkgs = pkgs; })
          ];

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
