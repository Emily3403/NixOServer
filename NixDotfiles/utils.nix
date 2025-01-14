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
  makeOciContainerIP = id: "10.88.1.${toString (id + 1)}";

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


}
