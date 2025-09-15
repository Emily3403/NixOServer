{ config, lib }:

{
  # https://stackoverflow.com/a/54505212
  recursiveMerge = with lib; attrList:
    let
      f = attrPath:
        zipAttrsWith (n: values:
          if tail values == [ ]
          then head values
          else if all isList values
          then unique (concatLists values)
          else if all isAttrs values
          then f (attrPath ++ [ n ]) values
          else last values
        );
    in
    f [ ] attrList;


  makeNixContainerIP = id: "192.168.7.${toString (id + 1)}";

#  makeOciContainerUID = id: "";

  makeNginxMetricConfig = service: ip: port /* str */: {
    forceSSL = true;
    enableACME = true;
    locations."/${service}-metrics".proxyPass = "http://${ip}:${port}/metrics";
  };

  # TODO: Merge this somehow into the above
  makeNginxBearerMetricConfig = service: ip: port /* str */: {
    forceSSL = true;
    enableACME = true;
    locations."/${service}-metrics" = {
      proxyPass = "http://${ip}:${port}/metrics";
      extraConfig = "auth_basic off;";  # Authentication is handled by the Bearer Token
    };
  };

  # Oci-Container Stuff
  makeOci-netName = name: "podman-${name}";

  makeOci-subnet = id: "10.42.${toString id}.0/24";
  makeOci-gateway = id: "10.42.${toString id}.254";

  makeOci-IP = id: num: "10.42.${toString id}.${num}";
  makeOci-mainIP = id: "10.42.${toString id}.1";
  makeOci-postgresIP = id: "10.42.${toString id}.2";
  makeOci-mysqlIP = id: "10.42.${toString id}.3";
  makeOci-redisIP = id: "10.42.${toString id}.4";

  makeOci-uid = id: "13${lib.strings.fixedWidthString 2 "0" (toString id)}0";
  makeOci-gid = id: "13${lib.strings.fixedWidthString 2 "0" (toString id)}0";

}
