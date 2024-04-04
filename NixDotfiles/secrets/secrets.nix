let
  ruwuschOld = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB/yrfThm1tdMr5hGiL8dRWb+OF/BOYk2NV36oKsH1lNFKuMlBLRx8NKaEUNrHuua2nJFLc5NFYpMm6czk6F5rePpkhgOypac0/zF1eJS1ebQurDWCAyOdeuCRxdvWaA9IbMP7EHzjWwkucgtF1Ke9RCKCb1WSFuAczOhMh+9SwVQzeIQXNEBV+8o3sQSEdkUTpDClOgyuPhbNwxOYbzJzdsBxyO2htB02GVvdgrZydINh63lthlBYv1819cEdZqG2bMWzvn43A0QHGrBtoQ7s3+D6GIn4pyXukrlQJqNyOi/xCkJQIKt+70IULtNrj+rWRX+GZoX9E5uD/Oz/k8NJhnaiGks7JFc2oKksKfmy2EHM2QnGV7NtYUlfXfPAhs2JYfo9VPMMY62Zy/pXIVd6NvOl34ofmXBoDfBMlhONl69OA7is/QiX0kZsMEnAe02KFW+atWdtIWBAtmb6eySHbOObpw2jDSL6hrO0bh7cQXuovfiR+EhbPcdB5RodBaphzMbPtGXKomlskmzHfYR7DZeq0IEHG/iY6OLOg/bgqMKdWqdQbMb5Ljog6SqlJJFG5GaiDgU/ZMRVaBh7up5N4YKnHiieesOJsv5VLg6JjKASmBVsTbRe/S7Wvz28Pz5bVNgsprfSH/5opdMzNALfzJnfJOhkTaKne5bpHz+Dw6s= root@ruwusch";
  ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlF4l8I+lbs3JxYRfnkULPhV+svAtoDAr0CtpjR6Rtj root@ruwusch";

  systems = [ ruwusch ];
in
{
  "Keycloak/DatabasePassword.age".publicKeys = [ ruwusch ];
  "Keycloak/AdminPassword.age".publicKeys = [ ruwusch ];

  "Nextcloud/AdminPassword.age".publicKeys = [ ruwusch ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ ruwusch ];

  "HedgeDoc.age".publicKeys = [ ruwusch ];
  "Transmission.age".publicKeys = [ ruwusch ];
  "Luk-Docs.age".publicKeys = [ ruwusch ];
  "Wireguard.age".publicKeys = [ ruwusch ];
  "PhotoPrism.age".publicKeys = [ ruwusch ];
  "Tandoor.age".publicKeys = [ ruwusch ];
  "Piwigo-Mariadb.age".publicKeys = [ ruwusch ];

  "SSHKeys/wiki-js.age".publicKeys = [ ruwusch ];
}
