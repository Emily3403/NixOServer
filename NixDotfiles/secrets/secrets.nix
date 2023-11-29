let
  ruwusch = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB/yrfThm1tdMr5hGiL8dRWb+OF/BOYk2NV36oKsH1lNFKuMlBLRx8NKaEUNrHuua2nJFLc5NFYpMm6czk6F5rePpkhgOypac0/zF1eJS1ebQurDWCAyOdeuCRxdvWaA9IbMP7EHzjWwkucgtF1Ke9RCKCb1WSFuAczOhMh+9SwVQzeIQXNEBV+8o3sQSEdkUTpDClOgyuPhbNwxOYbzJzdsBxyO2htB02GVvdgrZydINh63lthlBYv1819cEdZqG2bMWzvn43A0QHGrBtoQ7s3+D6GIn4pyXukrlQJqNyOi/xCkJQIKt+70IULtNrj+rWRX+GZoX9E5uD/Oz/k8NJhnaiGks7JFc2oKksKfmy2EHM2QnGV7NtYUlfXfPAhs2JYfo9VPMMY62Zy/pXIVd6NvOl34ofmXBoDfBMlhONl69OA7is/QiX0kZsMEnAe02KFW+atWdtIWBAtmb6eySHbOObpw2jDSL6hrO0bh7cQXuovfiR+EhbPcdB5RodBaphzMbPtGXKomlskmzHfYR7DZeq0IEHG/iY6OLOg/bgqMKdWqdQbMb5Ljog6SqlJJFG5GaiDgU/ZMRVaBh7up5N4YKnHiieesOJsv5VLg6JjKASmBVsTbRe/S7Wvz28Pz5bVNgsprfSH/5opdMzNALfzJnfJOhkTaKne5bpHz+Dw6s= root@ruwusch";

  systems = [ ruwusch ];
in
{
  "KeyCloak/DatabasePassword.age".publicKeys = [ ruwusch ];
  "KeyCloak/AdminPassword.age".publicKeys = [ ruwusch ];

  "Nextcloud/AdminPassword.age".publicKeys = [ ruwusch ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ ruwusch ];

  "HedgeDoc/EnvironmentFile.age".publicKeys = [ ruwusch ];
  "Transmission/EnvironmentFile.age".publicKeys = [ ruwusch ];

  "SSHKeys/Wiki-js/key.age".publicKeys = [ ruwusch ];
  "SSHKeys/Duplicati/nixie.age".publicKeys = [ ruwusch ];

  "Borg/nixie.age".publicKeys = [ ruwusch ];
}
