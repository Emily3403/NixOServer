{ pkgs, config, lib, ... }:
{
  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "wireguard";
        containerIP = "192.168.7.110";
        containerPort = 80;
        makeNginxConfig = false;

        # TODO: Use a localForward to have a fallback port
        bindMounts = {
          "${config.age.secrets.Wireguard.path}".hostPath = config.age.secrets.Wireguard.path;
        };

        cfg = {
          networking.wireguard.interfaces.wg0 = {
            ips = [ "192.168.2.1/24" ];
            listenPort = 51820;
            privateKeyFile = config.age.secrets.Wireguard.path;

            peers = [
              {
                name = "emily";
                publicKey = "";
              }
            ];
          };
        };
      }
    )
  ];
}
